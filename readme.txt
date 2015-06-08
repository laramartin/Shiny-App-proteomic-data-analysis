####### Lara Martin - proyecto final de posgrado #######


############################
PASOS PARA EJECUTAR MS-app
############################

Pasos:  

1. Instalación de librerías

	1.1 abrir el script setup.R con RStudio y ejecutarlo (run). Se instalarán las librerías necesarias. 
	
	1.2 Si hay problemas con la instalación, abrir RStudio como administrador. Clic con el botón derecho en el icono de RStudio -> Run as administrator 

2. JAVA

	2.1 Se necesita JAVA porque la función runMSGF() de la librería "MSGFplus" utiliza java. 

	2.2 Instalar manualmente de http://www.java.com/en/download/manual.jsp 

		2.2.1 Instalar la version 64 bits si se usa el RStudio de 64 bits.

		2.2.2 Añadir a las variables de entorno: JAVA_HOME -> la carpeta donde se instala el java.

			- Botón derecho en "Computer" -> System Properties -> Environment Variables -> New Variable -> name: JAVA_HOME value: path to JAVA (for example mine is:  C:\Program Files\Java\jre1.8.0_45)

		2.2.3 Crear o modificar el PATH y añadir %JAVA_HOME%\bin

			- "Computer" -> System Properties -> Environment Variables -> si la variable "path" no existe, crear una nueva. Si existe solo hay que añadir el value al final. Value: %JAVA_HOME%\bin

	2.3 Reiniciar RStudio


3. Abrir los scripts server.R y ui.R con RStudio -> ejecutar la aplicación (botón "Run App")

