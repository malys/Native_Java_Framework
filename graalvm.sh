#!/bin/bash

export FOLDER=/D/temp
export EIGHT=/D/prog/jdk1.8.0_201/
export GRAAL=/D/prog/jdk/ # /usr/lib/jvm/graalvm-ce-19.1.1/
export ONZE=/D/prog/jdk-11.0.4+11-Hotspot/
export OPEN=/D/prog/jdk-11.0.4+11-OpenJ9/
export KPATH=/D/Developpement/archi/lyra-keystore/all-modules/keystore-backend/impl/target
export RHSSOPATH=/D/rh-sso-7.3/
export BOMB=bombardier #/D/prog/bombardier
export SUPER=/D/prog/sb
declare -a arr=(
"CountUppercase" \
)

function stress(){
	$BOMB -c 3 -d 8s --print=r -l $1
	#$SUPER -u "http://localhost:8080/admin/keystore" -c 3 -n 50
}

function os(){
	unameOut="$(uname -s)"
	case "${unameOut}" in
		Linux*)     machine=Linux;;
		Darwin*)    machine=Mac;;
		CYGWIN*)    machine=Cygwin;;
		MINGW*)     machine=MinGw;;
		*)          machine="UNKNOWN:${unameOut}"
	esac
	echo ${machine}
}

function killK(){
	kill -INT $(ps ax | grep $1| fgrep -v grep | awk '{ print $1 }')
	sleep 3	
	kill $(ps ax | grep $1| fgrep -v grep | awk '{ print $1 }')
	sleep 1	
}

function keystore(){
	sep
	${1}bin/java $3 -jar $2 | grep started &
	sleep 6
	mem java
	stress http://localhost:8080/admin/keystore
	killK java
	sep
}

function pass(){
	export ELASTICSEARCH_URL=http://server:9200
	export SPRING_REDIS_HOST=server
	export SPRING_SETTINGS_DS_URL=https://server:8445
	export KEYSTORE_BINDER=LOCAL
	export SPRING_PROFILES_ACTIVE=dev
	sep
	${1}bin/java $2 -jar pass.jar | grep "Started PassServerApplication in" &
	sleep 15
	mem java
	stress http://localhost:8081/internal/actuator/health/redis
	killK java
	sep
}

function rhsso(){
	sep
	export JBOSS_HOME=${RHSSOPATH}
	export JAVA_HOME=$1 
	export JAVA_OPTS=$2 
	#echo $JAVA_HOME $JBOSS_HOME $JAVA_OPTS
	${RHSSOPATH}bin/standalone.bat | grep  "services ont d"  &
	sleep 30
	mem java
	killK standalone
	killK java
	sep
}

function mem(){	
	currentOS=$(os)
	if [ "$currentOS" == "Linux" ]
	then
		#grep VmPeak /proc/$(ps ax | grep $1| fgrep -v grep | awk '{ print $1 }')/status
		ps afu | awk 'NR>1 {$5=int($5/1024)"M";}{ print;}' | grep $1
	else
		wmic process where caption=\"$1.exe\"  get WorkingSetSize
	fi	   
}

function sep(){
	echo "****************************************************************"
}

if [ "$1" == "basic" ] 
then
	cd $FOLDER

	for BYTE in "${arr[@]}"
	do
		export FILE=$BYTE.java
		echo "------------------ $BYTE --------------"
		${EIGHT}bin/javac $FILE
		echo OpenJDK8
		${EIGHT}bin/java $BYTE &
		mem java
		sleep 5
		sep
		
		${ONZE}bin/javac $FILE
		echo OpenJDK11
		${ONZE}bin/java $BYTE  &
		mem java
		sleep 5
		sep
		
		${ONZE}bin/java -Xshare:dump 
		echo OpenJDK11 CDA
		${ONZE}bin/java -Xshare:on $BYTE  &
		mem java
		sleep 5
		sep
		
		${OPEN}bin/javac $FILE
		echo OpenJ9
		${OPEN}bin/java -Xshareclasses:name=CountUppercase $BYTE  &
		mem java
		sleep 5
		sep
		
		${GRAAL}bin/javac $FILE
		#echo Compile GraalVM - Only for Linux
		#${GRAAL}./native-image $BYTE  &	
		#echo GraalVM Native - Only for Linux
		#./countuppercase  &
		#mem java
		#sep
		
		echo GraalVM disabled
		
		#${GRAAL}bin/java -Dgraal.ShowConfiguration=info  -version
		${GRAAL}bin/java -XX:-UseJVMCICompiler $BYTE  &
		mem java
		sleep 5
		sep
		
		echo GraalVM EE - Only for Windows
		${GRAAL}bin/java $BYTE & #${GRAAL}bin/java -Dengine.Mode=throughput $BYTE best optimization after cycle
		mem java
		sleep 5
		sep
		
		echo GraalVM Community
		${GRAAL}bin/java -Dgraal.CompilerConfiguration=community $BYTE &
		mem java
		sleep 5
		sep
	done

#	read -n1 -r -p "Press any key to continue..." key
fi	
if [ "$1" == "keystore" ] 
then
	echo "------------------ $KPATH --------------"
	echo OpenJDK8
	keystore $EIGHT $KPATH/keystore-impl-runner.jar

	echo OpenJDK11
	keystore $ONZE $KPATH/keystore-impl-runner.jar

	echo OpenJDK11 CDA
	${ONZE}bin/java -Xshare:dump
	keystore $ONZE $KPATH/keystore-impl-runner.jar -Xshare:on

	echo OpenJDK11 CDA Application
	FILE=keystore.jsa
	if [ ! -f "$FILE" ]; then
		${ONZE}bin/java -XX:DumpLoadedClassList=classes.lst -Xshare:dump -XX:SharedArchiveFile=$FILE --class-path  $KPATH/keystore-impl-runner.jar 
	fi
	keystore $ONZE $KPATH/keystore-impl-runner.jar "-Xshare:on -XX:SharedArchiveFile=$FILE"
	
	echo GraalVM EE - Only for Windows
	keystore ${GRAAL} $KPATH/keystore-impl-runner.jar

	echo GraalVM Community
	keystore ${GRAAL} $KPATH/keystore-impl-runner.jar -Dgraal.CompilerConfiguration=community 

	echo OpenJ9
	keystore $OPEN $KPATH/keystore-impl-runner.jar
fi

if [ "$1" == "rhsso" ] 
then
	echo "------------------ $RHSSOPATH --------------"
	echo OpenJDK8
	rhsso $EIGHT
	
	echo OpenJDK11
	rhsso $ONZE 
	
	echo GraalVM Community
	rhsso ${GRAAL} -Dgraal.CompilerConfiguration=community 

	echo OpenJ9
	rhsso $OPEN
	
	echo GraalVM EE - Only for Windows
	rhsso ${GRAAL} 

	
	#Not compatible
	#echo OpenJDK11 CDA
	#${ONZE}bin/java -Xshare:dump
	#rhsso $ONZE -Xshare:on
	#
	#echo OpenJDK11 CDA Application
	#FILE=rhsso.jsa
	#if [ ! -f "$FILE" ]; then
	#	${ONZE}bin/java -XX:DumpLoadedClassList=classes.lst -Xshare:dump -XX:SharedArchiveFile=$FILE --class-path  $KPATH/keystore-impl-runner.jar 
	#fi
	#rhsso $ONZE "-Xshare:on -XX:SharedArchiveFile=$FILE"


fi

if [ "$1" == "springboot" ] 
then
	echo "------------------ Pass --------------"
	echo OpenJDK11
	pass $ONZE 
	
	echo OpenJDK11 CDA
	${ONZE}bin/java -Xshare:dump
	pass $ONZE -Xshare:on
	#
	echo OpenJDK11 CDA Application
	FILE=pass.jsa
	if [ ! -f "$FILE" ]; then
		${ONZE}bin/java -XX:DumpLoadedClassList=classes.lst -Xshare:dump -XX:SharedArchiveFile=$FILE --class-path  pass.jar 
	fi
	pass $ONZE "-Xshare:on -XX:SharedArchiveFile=$FILE"
	
	echo GraalVM Community
	pass ${GRAAL} -Dgraal.CompilerConfiguration=community 

	echo OpenJ9
	pass $OPEN
	
	echo GraalVM EE - Only for Windows
	pass ${GRAAL} 

fi

if [ "$1" == "jlink" ] 
then
	echo "------------------ $1 --------------"

	echo OpenJDK11
	cd $FOLDER
	
	
	for BYTE in "${arr[@]}"
	do
		mods=$(${ONZE}bin/jdeps --print-module-deps $BYTE.class)
		#echo $mods
		${ONZE}bin/jlink --no-header-files --no-man-pages --compress=2 --strip-debug --add-modules  $mods  --output java-$BYTE
		du -hs java-$BYTE
		java-$BYTE/bin/java $BYTE 
	done
fi

if [ "$1" == "native" ] 
then
	echo "------------------ Native --------------"
	echo OpenJDK8
	java  -jar -XX:-UseJVMCICompiler $KPATH/keystore-impl-runner.jar | grep started &
	sleep 6
	mem java
	stress http://localhost:8080/admin/keystore
	killK java 
	sep
	
	$KPATH/keystore-impl-runner  | grep started  &
	sleep 2
	mem keystore
	stress http://localhost:8080/admin/keystore
	killK keystore 
	sep	
fi

if [ "$1" == "framework" ] 
then
	echo "------------------ Framework --------------"
	echo Micronaut
	java  -jar save/micronaut.jar | grep "Startup compl" &
	sleep 6
	mem java
	stress http://localhost:8080/conferences/random
	killK java 
	sep

	echo Micronaut Native
	save/micronaut  | grep "Startup compl"  &
	sleep 2
	mem micronaut
	stress http://localhost:8080/admin/keystore
	killK micronaut 
	sep	

	echo Spring
	java  -jar save/spring.jar | grep Started &
	sleep 8
	mem java
	stress http://localhost:8080/conferences/random
	killK java 
	sep
	
	echo Micronaut Spring
	java  -jar save/micronaut-spring10.jar  &
	sleep 8
	mem java
	stress http://localhost:8080/conferences/random
	killK java 
	sep
	
	echo "Micronaut Spring Native (not really native)"
	save/micronaut-spring10 &
	sleep 4
	mem java
	stress http://localhost:8080/conferences/random
	killK java
	sep

	echo Quarkus 
	java  -jar save/quarkus.jar | grep started  &
	sleep 6
	mem java
	stress http://localhost:8080/conferences/random
	killK java 
	sep
	
	echo Quarkus Native
	save/quarkus  | grep started  &
	sleep 2
	mem quarkus
	stress http://localhost:8080/conferences/random
	killK quarkus
	sep

	echo Quarkus Spring
	java  -jar save/quarkus-spring.jar | grep started  &
	sleep 6
	mem java
	stress http://localhost:8080/conferences/random
	killK java 
	sep

	echo Quarkus Spring Native
	save/quarkus-spring  | grep started  &
	sleep 2
	mem quarkus
	stress http://localhost:8080/conferences/random
	killK quarkus
	sep

	echo Helidon
	java  -jar save/helidon.jar | grep started  &
	sleep 6
	mem java
	stress http://localhost:8080/conferences/random
	killK java 
	sep

	#echo Helidon Native -> Failed
	#save/quarkus-spring  | grep started  &
	#sleep 2
	#mem quarkus
	#stress http://localhost:8080/conferences/random
	#killK quarkus
	#sep


fi

