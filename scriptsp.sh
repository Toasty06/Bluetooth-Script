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
t=${result2#*"REG_BINARY"}
ba=${t%"(...)"*}
echo $ba | sed 's/<//g' | sed 's/>//g'
echo Enter device address:
read var2
cmd2="cd ControlSet001\Services\BTHPORT\Parameters\Keys\n cd $var\nhex $var2\nq\n"
result=$(echo -e "$cmd2" | chntpw -e SYSTEM)
echo $result

if [[ $result == *":00000"* ]]; then
  echo "It's there!"
  tmp=${result#*":00000"}
  b=${tmp%"g@..."*}
  key=$(echo $b | sed 's/ //g')
  echo $key
fi

varp=$(echo $var | sed -e 's/../&:/g' -e 's/:$//')
varp=$(echo ${varp^^})
varp2=$(echo $var2 | sed -e 's/../&:/g' -e 's/:$//')
varp2=$(echo ${varp2^^})
cd /var/lib/bluetooth/
cd $varp
cd $varp2
value1=`cat info`
value=${value1#*"Key="}
value=${value%"Type"*}
if [[ $value1 == *"$value"* ]]; then
    #sed 's/$value/$key/' info > output.txt
    file="info"
    echo $key
    echo $value
    string2=${value#"|"}
    v2=${value::-1}
    echo $v2
    sed "s|$v2|$key|gi" info > info2
    rm info
    mv info2 info
    #sed -i "s/$value/ZZ/g" "$file"
    systemctl restart bluetooth
fi
read