check_image_building is the script run by opsview to check the outcome of the image building process

Components:
- check_image_building.py - this is the python script run to perform the check. It should be put in /usr/local/nagios/libexec/nrpe_local/, owner nrpe:nrpe, permissions 550
- check_image_building_cpouta_devel.json - this is the configuration file that tells the python script which are the log files to be checked. Its path is a mandatory argument for the python script. It should be put in /etc/nrpe.d, owner nrpe:nrpe, permissions 600
- check_image_building_cpouta_devel.cfg - this is the configuration file for the nrpe daemon. It just defines that the command "check_image_building_cpouta_devel" means running check_image_building.py using the path of check_image_building_cpouta_devel.json as the mandatory argument. It should be put in /etc/nrpe.d, owner nrpe:nrpe, permissions 600

If a new environment needs to be checked:
- duplicate check_image_building_cpouta_devel.json and adapt it for the new environment
- duplicate check_image_building_cpouta_devel.cfg and adapt it for the new json configuration file
- systemctl restart nrpe
- add the new service check using the command defined in the new cfg file in opsview
- add the service check to the list of service checks of host imgbuilder

Note: if nrpe is having issues reading the log files to be checked, then check the permissions of the log files, including active selinux policies
