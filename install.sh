printf "\n---       Your environment will start installing                      ---\n\n"

if [ ! -d "/vagrant" ]; then
    printf "\n\n--- Cheching Repository ---\n\n"
    git clone https://github.com/gregbkr/geth-truffle-docker.git devchain && cd devchain
fi

printf "/// Give a node name : "; 
read n ; 
echo "export GETH_NODE=$n" >> ~/.profile && source ~/.profile; 

printf "\n---       Next time just type ./start.sh to launch docker             ---"
printf "\n---       Now, docker is ready to start :)                            ---"

chmod 755 start.sh
./start.sh
