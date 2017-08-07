# Ethereum environment with docker-compose + smart contract with truffle #

![devchain-infra.png](https://github.com/gregbkr/geth-truffle-docker/raw/master/media/devchain-infra.png)

## Description

This compose will give you in on command line:
- **ethereum go-client** (geth) running on port 8544 with
  - A default account, already unlocked
  - Connected to devchain (network 2017042099)
  - Mining the blocks
  - Data are saved out of the container on your host in `/root/.ethereum`, so no problem if you delete the container
- **Testrpc** eth-node running a test network on port 8545
- **Truffle**: where you can test and deploy smart contracts
- **Netstats**: which will collect and send your node perf to our devchain dashboard on http://factory.shinit.net:15000

We strongly encourage to read all this document to understand each step, but if you are in hurry and have to start working asap just go to Annexe Quick Install.

## 0. Prerequisit
- A linux VM, preferable ubuntu 14.x or 16.x. If you are on windows or MAC, please use [Vagrant](#vagrant) --> see in annexes 
- [Docker](#docker) v17 and [docker-compose](#docker-compose) v1.15 
- This code: `git clone https://github.com/gregbkr/geth-truffle-docker.git devchain && cd devchain`
- Create an environment var to declare your geth node name: `echo "export GETH_NODE=<YOUR_NODE_NAME>" >> ~/.profile && source ~/.profile`
- Check your node name: `echo $GETH_NODE`

## 1. Run containers

- Run the stack: `docker-compose up -d`
- Check geth is up and answering locally: `curl -X POST --data '{"jsonrpc":"2.0","method":"eth_syncing","params":[],"id":1}' localhost:8544`
- Check testrpc node is running: `curl -X POST --data '{"jsonrpc":"2.0","method":"eth_syncing","params":[],"id":1}' localhost:8545`

## 2. Geth
- Check container logs: `docker logs -f geth`
- Start shell in the geth container: `sudo docker exec -it geth sh` 
- Interact with geth:
  - List account: `geth --datadir=/root/.ethereum/devchain account list`
  - To see your keys: `cat /root/.ethereum/devchain/keystore/*`
  - Backup the account somewhere safe. For example, I saved this block for my wallet (carefull, you can steal my coins with these info):
`{"address":"6e068b2fcf3ed73d5166d0b322fa10e784b7b4fe","crypto":{"cipher":"aes-128-ctr","ciphertext":"0d392da6deb66b13c95d1b723ea51a53ab58e1f7555c3a1263a5b203885b9e51","cipherparams":{"iv":"7a919e171cda132f375afd5f9e7c2ba1"},"kdf":"scrypt","kdfparams":{"dklen":32,"n":262144,"p":1,"r":8,"salt":"1f3f814262b9a4ce3c2f3e1cabb5788f0520101f00598aa0b84bbda08ceaaf31"},"mac":"8e8393e86fe2278666ec26e9956b49adc25bc2e7492d5a25ee30e8118dd17441"},"id":"71aa2bfd-ee91-4206-ab5e-82c38ccd071f","version":3}/`
  - The account is on your vm too, exit docker `exit` then type `sudo ls /var/lib/docker/volumes/devchain_geth/_data/devchain`. From this location you can save or import another account (just copy/paste your key file)

- If needed, create new account with:
  - Create password: `echo "Geneva2017" > /root/.ethereum/devchain/pw2`
  - create account: `geth --datadir=/root/.ethereum/devchain account new --password /root/.ethereum/devchain/pw2`

- Mining (y/n)? In `docker-compose.yml` section `geth/command` add/remove `--fast --mine` and run again `docker-compose up -d`

- Check that you can see your node name on our netstat dashboard: http://factory.shinit.net:15000

- Use python to check your node, and later send ether: 
  - Install tools: `sudo apt-get install -y python3 python3-pip && pip3 install web3`
  - Check your node: `python3 checkWeb3.py`
  - Want to send ether? Edit `remote`, `amountInEther` and comment `exit()`, and run the same script

## 3. Truffle

#### 3.1 Description

Truffle will compile, test, deploy your smart contract.
In `/dapp` folder, there are few exemples of easy smart contract:
- **MetaCoin**: default truffle contract you get when typing `truffle init`. It is a basic coin and you can `getBalance()` or `sendCoin()` token
- **HelloWorld**: Just one function, display a single message when calling the function `greeter()`
- **Counter**: From 0, increment the counter each time you run `increment()`, then see the result `getCount()`

Each project has test functions (doing the same tests), in solidity `./test/*.sol` or in javascript `./test/*.js` 


#### 3.2 Try truffle with MetaCoin:
- Go in truffle container:  `docker exec -it truffle sh`
- Go to metaCoin project: `cd /dapps/MetaCoin`
- Check configuration: `cat truffle.js` <-- it should map with `geth:8544` and `testrpc:8545`
- Test the contract against testrpc node: `truffle test --network testrpc`
- Test against our devchain network: `truffle test --network devchain`
- If warning message: `authentication needed: password or unlock` --> you need to unlock your wallet!

#### 3.3 Test our helloWorld dapp
- Customize the output of the helloWorld: `migrations/2_deploy_contracts.js`, edit: `I am Groot!`
- Navigate to the folder: `cd /dapp/HelloWorld`
- Test against testrpc: `truffle test --network testrpc`
- Test against devchain: `truffle test --network devchain`

#### 3.4 Send your helloWorld contract to devchain
- Go to project dir: `cd /dapp/HelloWorld`
- Send/migrate contract to devchain: `truffle migrate --network devchain` <-- you shoud get the contract number: `Greeter: 0xbbe920b156febdb475d5139c8d86201b5a84b2fd`

#### 3.5 Interact with the contract from the truffle console:
- Access the console: `truffle console --network devchain`
- See last Greeter deployed: `Greeter.deployed()`
- Greeter address: `Greeter.address`
- Run the greet function(the main one) of our contract: `Greeter.at('0xbbe920b156febdb475d5139c8d86201b5a84b2fd').greet()`
- We can map our contract to an object: `var greeter = Greeter.at('0xbbe920b156febdb475d5139c8d86201b5a84b2fd')`
- And simply call functions of this object: `greeter.greet()`

#### 3.6 Share you contract with others
For that you will need:
- The **contract address**: `0xbbe920b156febdb475d5139c8d86201b5a84b2fd`
- The **abi**: a description of the functions of our contract 
  - From our VM: install jq: `sudo apt-get install jq`
  - And display the abi: `cat dapp/HelloWorld/build/contracts/Greeter.json | jq -c '.abi'`
  - Result: `[{"constant":false,"inputs":[],"name":"kill","outputs":[],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"greet","outputs":[{"name":"","type":"string"}],"payable":false,"type":"function"},{"inputs":[{"name":"_greeting","type":"string"}],"payable":false,"type":"constructor"}]`
  - Go to a truffle's friend pc, and interact with your contract:
  - Create the abi: `abi=[{"constant":false,"inputs":[],"name":"kill","outputs":[],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"greet","outputs":[{"name":"","type":"string"}],"payable":false,"type":"function"},{"inputs":[{"name":"_greeting","type":"string"}],"payable":false,"type":"constructor"}]`
  - You can now run your contract function to see your custom message: `web3.eth.contract(abi).at('0xbbe920b156febdb475d5139c8d86201b5a84b2fd').greet()`

#### 3.7 New contract from template:
- Launch a new contract (a clone) from the template Greeter: `var greeter2 = Greeter.new("Hello gva")`
- Get the address: `greeter2`
- Check the output: `Greeter.at('0x0a4c092ed54bcec766b4da5f641d396494a26638').greet()`

#### 3.8 Within truffle, you can interact with your geth wallet:
- See account0 balance: `web3.fromWei(web3.eth.getBalance(web3.personal.listAccounts[0]))`
- Unlock your account: `web3.personal.unlockAccount(web3.personal.listAccounts[0], "17Fusion", 150000);`
- Send some ether: `web3.eth.sendTransaction({from:web3.personal.listAccounts[0], to:'0x41df2990b4efd225f2bc12dd8b6455bf1c07ff6d', value: web3.toWei(10, "ether")})`


## Annexes

### Quick Install
- For linux user : `wget https://raw.githubusercontent.com/gregbkr/geth-truffle-docker/master/install.sh; chmod 755 install.sh; ./install.sh`

- for Windows user :
   - do the procedure in below in Vagrant section
   - run `chmod 755 install.sh; ./install.sh`

### Vagrant
- Install Git for windows or similar command line that you can git. 
- Install the latest version of [vagrant](https://www.vagrantup.com/downloads.html) and [virtualbox](https://www.virtualbox.org/wiki/Downloads)
- Clone our repo and go at the root
- Create vagrant vm: `vagrant up`, and wait the vm to build
- Access the vm: `vagrant ssh`
- Access the files: `cd /vagrant/`
--> You are now in an ubuntu vm, you can continue the tuto!

### Docker
Install docker:
```
wget https://get.docker.com/ -O script.sh
chmod +x script.sh
sudo ./script.sh
sudo usermod -aG docker ${USER}
```
check docker version: `docker version`

Docker commands:
- List docker image: `docker image list`
- List docker container: `docker container list`

### Docker-compose
Replace 1.15.0 with latest version available on https://github.com/docker/compose/releases 
```
sudo -i
curl -L https://github.com/docker/compose/releases/download/1.15.0/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
exit
```
check docker-compose version `docker-compose version`

[Back to Prerequisit](#prerequisit)
