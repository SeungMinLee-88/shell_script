zonename=
    echo "12312"
zonename=$(dialog --stdout --title "My input box" --clear \
        --inputbox "Hi, this is a sample input box\n Try entering your name below:" \
        16 51 2)
echo $zonename
