## Steps to run MS-app

1. Libraries installation

  1.1 Open the setup.R script with RStudio and run it. The needed libraries will be installed. 

  1.2 If there are any problems during the installation, open RStudio as an admin. Right-click on the RStudio icon and select "Run as administrator". 

2. JAVA
  
  2.1 The function runMSGF() of the MSGFplus library needs java

  2.2 Install manually from http://www.java.com/en/download/manual.jsp 

    * Install the 64-bit version if you are using RStudio 64-bit. 
    
    * Add the environment variables: JAVA_HOME -> the folder where java is installed. 

      - Right-click on "Computer" -> System Properties -> Environment Variables -> New Variable -> name: JAVA_HOME value: path to JAVA (for example mine is:  C:\Program Files\Java\jre1.8.0_45)

    * Create or change the PATH and add %JAVA_HOME%\bin

      - "Computer" -> System Properties -> Environment Variables ->  if the variable "path" doesn't exist, create a new one. If it exists, just add the value at the end. Value: %JAVA_HOME%\bin

  2.3 Restart RStudio

3. Open the server.R and ui.R scripts with RStudio and run the App clicking on "Run App"

About the author: created by Lara Martin for Master thesis in 2015