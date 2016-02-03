# Remoter

Remote Linux Enumerator  version: 0.21 - beta


Remotely contacts Information Gathering in a Linux PC and feeds the results in HTML

	Usage:
	RemoteEnum.sh [-n SCAN_NAME] CONNECTION_TYPE [OPTIONS]

	CONNECTION_TYPE:

 		Bind and Wait:
	-b PORT	
	Example:
		RemoteEnum.sh -n scan -b 4444
 	Wait for a reverse (bash) shell at PORT and the scan is run when the shell arrives.

		Go and get it:
	-c IP:PORT
	Example:
		RemoteEnum.sh -n scan -c 192.168.1.15:4444
 	If we know that there is a 'bash' waiting at a certain PORT of the target IP 
we connect and enumerate the target

		Self Scan:
	-s
	Example:
		RemoteEnum.sh -n myPC -s
 	Runs the whole scan to the host PC (via /bin/bash)



	OPTIONS:
	-m				-- NOT YET
		Attempt to maintain shell access to the remote machine after the scan is finished.
	(Needs 'dupx' to work)

	-q
		Doesn't spawn firefox with the scan results.
	Instead prints the result location in terminal

