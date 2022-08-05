
screenshot_path="/mnt/onboard/"

SCRIPT=$(readlink -f $0)

SCRIPTPATH=$(dirname "$SCRIPT")

source $SCRIPTPATH/telegram.config

if [ -z "${TELEGRAM_BOT_TOKEN}" ] ||  [ -z "${CHAT_ID}" ] || [ `expr ${#TELEGRAM_BOT_TOKEN} + ${#CHAT_ID}` != 54 ];

    then

        echo "Invalid Telegram credentials, sorry."
        exit

fi



if ! [ "$(ping -c1 8.8.8.8)" ]

    then

        echo "error! no connection detected"
        exit

    else


        files=$(/usr/bin/find $screenshot_path -maxdepth 1 -type f -name "*.png")

        if [ -z "${files}" ];

            then

                echo "No screenshot found, sorry."

            else

                for i in $files;


                do


                    if $SCRIPTPATH/curl -k https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendPhoto -F chat_id=$CHAT_ID -F photo=@$i | grep -q 'error';

                        then

                            echo "Generic erorr! Please check Telegram credentials and internet connection."

                        else

                            ./bin/rm $path$i
                    fi

                done

        fi
fi
