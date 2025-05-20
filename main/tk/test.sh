y() {
        local x=0
        echo a | while read a; do
        x=1
done
echo $x
}

y
