echo IMPORTANT
echo "-First pair the device with your Linux Install"
echo "->Pair the device with your Windows Install"
echo "->Mount your Windows Partion on /mnt in Linux"
echo "->Make sure chntpw is installed"
echo "->Press Enter and follow the instrucions"
read


cd /mnt/Windows/System32/config/
result1=$(echo -e "cd ControlSet001\Services\BTHPORT\Parameters\Keys\nls\nq\n" | chntpw -e SYSTEM)
t=${result1#*"key name"}
ba=${t%"(...)"*}
echo $ba | sed 's/<//g' | sed 's/>//g'
echo Enter adapter address:
read var
echo --------------------
cmd="cd ControlSet001\Services\BTHPORT\Parameters\Keys\n cd $var\nls\nq\n"
result2=$(echo -e "$cmd" | chntpw -e SYSTEM)
#echo $result2
ba=${result2#*"REG_BINARY"}
ba=${ba#*"REG_BINARY"}
ba=${ba%"(...)"*}


ba1=${ba%"REG_BINARY"*}
ba1=${ba%"REG_BINARY"*}

ba2=${ba#*"REG_BINARY"}

ba2=${ba2#*"<"}
ba2=${ba2%">"*}
ba1=${ba1#*"<"}
ba1=${ba1%">"*}

echo $ba1
echo $ba2
echo Enter device address:
read var2
cmd2="cd ControlSet001\Services\BTHPORT\Parameters\Keys\n cd $var\nhex $var2\nq\n"
result=$(echo -e "$cmd2" | chntpw -e SYSTEM)
#echo $result

if [[ $result == *":00000"* ]]; then
  echo "It's there!"
  tmp=${result#*":00000"}
  b=${tmp%"g@..."*}
  key=$(echo $b | sed 's/ //g')
fi

#varp=$(echo $var | sed -e 's/../&:/g' -e 's/:$//')
varp=$(echo ${var^^} | sed -e 's!\.!!g;s!\(..\)!\1:!g;s!:$!!')

varp2=$(echo ${var2^^} | sed -e 's!\.!!g;s!\(..\)!\1:!g;s!:$!!')

cd /var/lib/bluetooth/
cd $varp
cd $varp2
value1=`cat info`

value=${value1#*"Key="}
value=${value%"Type"*}
echo 1
if [[ $value1 == *"$value"* ]]; then
    echo 2

    #sed 's/$value/$key/' info > output.txt
    file="info"
    string2=${value#"|"}
    echo 3
    #echo $value
    v2=${value::-1}
    #echo $v2
    sed -e "s|$v2|$key|gi" info > info2
    echo 4
    rm info
    mv info2 info
    #sed -i "s/$value/ZZ/g" "$file"
    systemctl restart bluetooth
fi
read