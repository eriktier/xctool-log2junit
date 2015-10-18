# xctool-log2junit

##Why this project ?

Before that i need to explain why [xctool](https://github.com/facebook/xctool)  was my favorites companion to execute my unit tests.

- Only because of the unit test reporter abstraction (the result output is a Junit format XML)

Why i want to change that ? 

- xctool is to big ... a lot of classes to finaly just a xcodebuild wrapper ?
- my unit tests are well excecuted on my computer with xctool but failed on my continuous integration servers ...
- my unit tests are well excecuted on my computer with xcodebuild and my continuous integration servers too.
- My dream what to use xcodebuild and generate a Junit formated results

I don't want to use xctool in my projects. 


##Sonar integration 
Change run.sonar.sh script or use [my updated version](./run-sonar.sh).

**This**
```
testIsInstalled xctool
testIsInstalled gcovr
testIsInstalled oclint
```

**By this**
```
testIsInstalled xctool-log2junit
testIsInstalled gcovr
testIsInstalled oclint
```

---

**This**
```
if [[ "$workspaceFile" != "" ]] ; then
	xctoolCmdPrefix="xctool -workspace $workspaceFile -sdk iphonesimulator ARCHS=i386 VALID_ARCHS=i386 CURRENT_ARCH=i386 ONLY_ACTIVE_ARCH=NO"
else
	xctoolCmdPrefix="xctool -project $projectFile -sdk iphonesimulator ARCHS=i386 VALID_ARCHS=i386 CURRENT_ARCH=i386 ONLY_ACTIVE_ARCH=NO"
fi	
```

**By this**
```
if [[ "$workspaceFile" != "" ]] ; then
	xctoolCmdPrefix="xcodebuild -workspace $workspaceFile -sdk iphonesimulator ARCHS=i386 VALID_ARCHS=i386 CURRENT_ARCH=i386 ONLY_ACTIVE_ARCH=NO"
else
	xctoolCmdPrefix="xcodebuild -project $projectFile -sdk iphonesimulator ARCHS=i386 VALID_ARCHS=i386 CURRENT_ARCH=i386 ONLY_ACTIVE_ARCH=NO"
fi	
```

---

**This**
```
echo -n 'Running tests using xctool'	
runCommand sonar-reports/TEST-report.xml $xctoolCmdPrefix -scheme "$testScheme" -reporter junit GCC_GENERATE_TEST_COVERAGE_FILES=YES GCC_INSTRUMENT_PROGRAM_FLOW_ARCS=YES test

```

**By this**
```
echo -n 'Running tests using xcodebuild'
mkdir -p sonar-reports/
runCommand $xctoolCmdPrefix -scheme "$testScheme" GCC_GENERATE_TEST_COVERAGE_FILES=YES GCC_INSTRUMENT_PROGRAM_FLOW_ARCS=YES test > xcodebuild-test.log

echo -n 'Converting xcodebuild log to Junit'
runCommand xctool-log2junit xcodebuild-test.log -o sonar-reports/TEST-report.xml 
```	

##Jenkins integration 

TO BE DONE

- add a build phase script (to convert log to Junit formated results)
- add a post build action to push those results


