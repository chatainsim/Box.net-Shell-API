get_ticket() {
  TICKET=`curl -s "https://www.box.com/api/1.0/rest?action=get_ticket&api_key=$API" | awk -F "<ticket>" {'print $2'} | awk -F "</ticket>" {'print $1'}`
}
display_auth_url() {
  echo "Please open this URL to authorize the application :"
  echo "https://www.box.com/api/1.0/auth/"$TICKET | sed 's/ //g'
  read test
}
get_token() {
  URL_TOKEN=`echo "https://www.box.com/api/1.0/rest?action=get_auth_token&api_key=$API&ticket="$TICKET | sed 's/ //g'`
  TOKEN=`curl -s "$URL_TOKEN" | awk -F "<auth_token>" {'print $2'} | awk -F "</auth_token>" {'print $1'}`
#  echo $TOKEN > token.log
}
update_conf() {
  echo "API="\"$API\" > config.sh
  echo "TOKEN="\"$TOKEN\" | sed 's/ //g' >> config.sh
}
get_list() {
  curl https://www.box.com/api/2.0/folders/$folder_id \
  -H "Authorization: BoxAuth api_key=$API&auth_token=$TOKEN"
}
upload() {
  if [ -f "$filename" ];
  then
     curl https://upload.box.com/api/2.0/files/data \
     -H "Authorization: BoxAuth api_key=$API&auth_token=$TOKEN" \
     -F filename=@"$filename" \
     -F folder_id=$folder_id
  else
     echo -e "\nError, file specified does not exist.\n"
  fi
}
new_folder() {
  curl https://api.box.com/2.0/folders/0 \
  -H "Authorization: BoxAuth api_key=$API&auth_token=$TOKEN" \
  -d '{"name":"New Folder"}' \
  -X POST
}
usage() {
  echo "There is no help ... yet"
	echo ""
	echo "Man page for box.sh :"
	echo ""
	echo "For the first time, you need to authenticate box.sh with your box.net account."
	echo "To do this, please use -a or --auth parameter like this :"
	echo "      ./box.sh -a    or   ./box.sh --auth"
	echo ""
	echo "To list a director use :"
	echo "      ./box.sh -l ID_FOLDER   or   ./box.sh --list ID_FOLDER"
	echo ""
	echo "To upload a file use :"
	echo "      ./box.sh -u FILENAME    or ./box.sh --upload FILENAME"
	echo ""
}
check_api() {
if [ "$API" == "" ];
then
        echo ""
	echo "-------------------------------------------------------------------------"
        echo "You should add you api key in the config.sh file."
        echo "To get an API key go here : https://www.box.com/developers/services/edit/"
	echo "-------------------------------------------------------------------------"
        echo ""
        exit 1
fi
}
