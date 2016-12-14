# Tutorial for Installing PCSJudge in a Linux Distro




### Part 1 - Setting up your environment
- Install a Linux distro (e.g. Ubuntu 14.04)
	(It would be easier if this distro is already predefined to work with PHP5)
- Install the LAMP package - Apache2, PHP5 and MySql. Make sure that your current version is PHP5 typing:
```sh
$ php -v
```
- Check if it is all right with Apache installation just typing your server address in your browser, e.g., 
```sh
127.0.0.1
```




### Part 2 - Downloading SharifJudge
- Download SharifJudge from PCS' Github repository
- Move the folder to this directory (or your predefined server folder)
```sh
var/www/html 
```
- Unzip it
- Edit index.php and change it to development mode




### Part 3 - Setting up a database
- Access mysql's shell by typing (where **** is your password defined at the mysql's installation process)
```sh
$ mysql -uroot -p**** 
```
- Create a database for the Judge typing 
```sh
$ create database Judge;
```
- Exit the shell by typing 
```sh
$ exit
```



### Part 4 - Setting up SharifJudge
- in your Judge folder, edit setting the parameters needed as the instructions show
```sh
/application/config/database.php 
```
- Give to Twig folder access to be writable by PHP 
```sh
$ chown -R www-data:www-data /application/cache/Twig
```

- Type in you browser and follow all the instructions
```sh
localhost/Judge/index.php 
```
- it will be needed to move assignments and tester folders to another directory and give them the same permission as you did for Twig

###### OBS: Do not forget to install g++ for compiling C++ code!

