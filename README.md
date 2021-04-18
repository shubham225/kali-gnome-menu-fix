# kali-gnome-menu-fix
**Generate category wise folder structure menu for kali applications on kali GNOME environment**

This script will organize kali penetration tools in folders based on application category maintained in `/usr/share/applications/*.desktop` files.

![alt text](https://github.com/shubham225/kali-gnome-menu-fix/blob/main/imgs/unstructured_menu.png)

![alt text](https://github.com/shubham225/kali-gnome-menu-fix/blob/main/imgs/organized-menu.png)

## Running the Script
1. Clone the repository from github.
2. Open terminal and `cd` into the script directory and execute following commands to run the script.
```
chmod +x ./kali-gnome-menu-fix.sh
sh ./kali-gnome-menu-fix.sh
```
3. Execution may take time as it reads desktop files and identifies menu categories.
4. Restart GNOME shell by pressing ALT+F2 or logout and login again. 
5. Menu will be organized based on application category.

## License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details
