# WiX Installer Notes

*2020.12.18*

These are some old notes for the WiX (Windows Installer XML) toolset. Hopefully these will not be needed anytime soon.

## Useful links:

[WiX Toolset](http://wixtoolset.org/)

[InstEdit -- for viewing and comparing MSI files](http://www.instedit.com/ "InstEdit")

## Debugging MSI installer files
msiexec.exe is responsible for executing any *.msi file. 

To enable full logging during installation:

	msiexec.exe /I <file.msi> /L*vx log.txt

	/L enables logging
	'*' enables all output
	'v' enables verbose logging
	'x' enables extra debug information


MSI is a special type of database file in that it contains all of the content required for installation


## Windows Installer Codes

Package Code - GUID - Uniquely Identifies a MSI File

Product Code - GUID - Uniquely Identifies a product release -- changes usually with the product version

Upgrade Code - GUID - Uniquely Identifies a set of related products -- supports upgrade functionality


## Properties
Properties are used to store information (variables) 

Property contains a name and value

- name begins with letter or underscore followed by any combo of letters, numbers, underscores, periods
- value is just text

Scope:

- public 
	- letters in name must be all CAPS 
	- persist between the client side and server side phases of install
	- values can be specified on the command line
- private
	- any variable name other than all caps
	- persist only in the phase it's defined in
	- value can't be specified on command line

Details:

- Properties are stored into the Property table. 
- Property data can be dumped to log files
	- hence don't put any confidential information in properties
- Can be used in conditions

Required Properties:

- Product Code
- Product Language 
- Manufacturer
- Product Version
- Product Name


## Features and Components

Features:

- Contain 1 or more components
- can be visible to the user in the installer UI
- ex: product documentation
- represented in install wizard as a tree

Components:

- are set of resources that are install/removed together
	- file(s)
	- shortcuts
	- registry keys
- have a GUI identifier
- have what is called a keypath
- recommended that 1:1 mapping preserved between files and components
	- this is to not break resiliency - only file marked as the keypath can be repaired

Component Keypath:

- file or registry key used to detect the component
- enables Windows installer resiliency
	- whether or not it can be removed/repaired

## Installation Types

Simple:

- most common

Administrative:

- network administrator can install the application's source image to the network

Advertisement:

- only the interface for launching the app is installed
- when the user starts the app then on-demand installation occurs


## Phases of Install

- UI - client side (runs with user privileges)
	- can be turned off via command line (/q)
	- collects data from user
	- must not modify users system!
- Execution - server side (runs as LocalSystem)
	- All system changes must occur here
	- this phase is transactional and therefore reversible

## Sequences

- specify what action should be run and which order in which they are executed

Simple Install Sequences:
	
	1. InstallUISequence
	2. InstallExecuteSequence

Administrative Install Sequences:

	1. AdminUISequence
	2. AdminExecuteSequence

Advertisement Install Sequences:

	1. AdvtExecuteSequence


Sequence Table Columns:

1. Action - references a standard or custom action
2. Condition - optional expression that determines if action is executed
	- (Action is executed if expression evaluates to 'true' or is blank)
3. Sequence - defines the order in which the actions are executed


## Actions

[Standard Actions](https://msdn.microsoft.com/en-us/library/aa372023(v=vs.85).aspx)

Custom Action examples:

- set a directory location to install-time value (type 35 custom action)
- set a Windows Installer property to install-time value

### Type 1 Custom Action
- Calls a function in a DLL
- Must have the following C Function Signature:
	- UINT __stdcall MyFunction(MSIHANDLE hModule)
- DLL must be stored in the binary table of the MSI database
- DLL does not have to be copied to target system since it's in the database

### Type 2 Custom Action
- calls an executable stored in the binary table with a command line 
- EXE does not have to be copied to target system since it's in the database

### Type 17 / 18 Custom Actions
- calls a .DLL/.EXE that is installed with the product (installed by installer)
- must run as deferred and executed after install files standard action
- non-deffered actions must be executed after install finalize

### Type 19 Custom Action
- Displays an error message from a formatted string and terminates installation

### Type 34 Custom Action
- calls .EXE using a path from a DIRECTORY table entry

### Type 35 Custom Action
- sets an install directory from a formatted string

### Type 50 Custom Action
- calls .EXE using a path from a Windows Installer Property

### Type 51 Custom Action
- sets a property from a formatted string



## Conditions

Used in:

- sequences
- launch condition table
- feature and component conditions
- UI features

Comparison Operators (both strings and ints):

	Op	| Meaning
	-------------
	=   | Equal To
	<>  | Not equal to
	>   | Greater Than
	<   | Less Than
    >=  | Greater than or equal
    <=  | Less than or equal

Strings:

- Strings are compared lexicographically when using < and >
- = compares them with case sensitivity
- ~= compares them with case insensitivity

String specific operators:

	Op	| Meaning
	-------------
	><  | True if left string contains right string
	<<  | True if left string starts with right string
	>>  | True if left string ends with right string

Logical Operators:

	Op	| Meaning
	-------------
	AND | True if both sides are true
	OR  | True if at least one side is true
	XOR | True if one side is true and the other is not
	EQV | True if both sides are true or both are false
	IMP | True if left side is false or right side is true
	NOT | Negates the value of the logical expression to its right

- you can use a single property in a condition as well 
	- the expression evaluates whether the property has been defined
	- a property has been defined if has been given any value at all
- you can also environment variables %MyEnvVar in conditions
- you can probe Component/Feature keys to inspect the action/future or install/current state
	- $MyComp (Action State of component)
	- ?MyComp (Installed State of component)
	- &MyFeat (Action State of feature)
	- !MyFeat (Installed State of feature)

Action and Install State Values:

	State                   | Value | Meaning
	-----------------------------------------
	INSTALLSTATE_UNKNOWN    | -1    | No action for feature or component
	INSTALLSTATE_ADVERTISED |  1    | Advertised feature (features only)
    INSTALLSTATE_ABSENT     |  2    | Feature or component not present
    INSTALLSTATE_LOCAL      |  3    | Feature or component locally installed
    INSTALLSTATE_SOURCE     |  4    | Feature or component accessed from source

Built In Properties:

- Installed - set if product is installed locally
- REMOVE - set during uninstallation
- etc

## Formatted Text

- there is a special type of strings called "Formatted"

Formatted Strings:

	string         | Meaning
    -------------------------------------
	[PropertyName] | Replaced by the value of the property
	[DirectoryKey] | Replaced by the path of the directory
	[%EnvVar]      | Replaced by the value of the environment variable
	[#FileKey]     | Replaced by the full path to the file on the target machine

- Note the cost standard actions must be run before the [#FileKey] will work properly, otherwise it will return string.empty
	- CostInitialize, FileCost, CostFinalize

- You can format a string with multiple formats using the braces {} to encapsulate the desired string
	- {Here are two properties: [PropertyA] and [PropertyB]}

