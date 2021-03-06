## Description
This compose will give you:
- ethereum go-client (geth) running on port 8540 with
  - A default account, already unlocked
  - Connected to devchain (network 2017042099)
  - Mining the blocks
  - Data are saved out of the container on your host in `/root/.ethereum`, so no problem if you delete the container
- A testrpc eth-node running a test network on port 8545
- Truffle: where you can test and deploy a simple smart contract
- Netstats: which will collect and send your node perf to our devchain dashboard on http://factory.shinit.net:15000

## Prerequisit
- A linux VM, preferable ubuntu 14.x or 16.x
- Docker v17 and docker-compose v1.13
- This code: `git clone https://github.com/gregbkr/geth-truffle-docker.git devchain && cd devchain`

## Run containers

- Edit your node name in `docker-compose.yml` section `geth/command: '--identity xxxx`, and section `netstatsapi/environment/ INSTANCE_NAME=xxx`
- Run the stack: `docker-compose up -d`
- Check geth is up and answering locally: `curl -X POST --data '{"jsonrpc":"2.0","method":"eth_syncing","params":[],"id":1}' localhost:8540`
- Check testrpc node is running: `curl -X POST --data '{"jsonrpc":"2.0","method":"eth_syncing","params":[],"id":1}' localhost:8545`

## Geth
- Check container logs: `docker logs -f geth`
- Go in the geth container: `docker exec -it geth sh`
- List account: `geth --datadir=/root/.ethereum/devchain account list`
- Backup the account somewhere safe:
  - Run this command: `cat /root/.ethereum/devchain/keystore/*`
  - And save the output. For example, I saved this block for my wallet (carefull, you can steal my coins with these info):
`{"address":"6e068b2fcf3ed73d5166d0b322fa10e784b7b4fe","crypto":{"cipher":"aes-128-ctr","ciphertext":"0d392da6deb66b13c95d1b723ea51a53ab58e1f7555c3a1263a5b203885b9e51","cipherparams":{"iv":"7a919e171cda132f375afd5f9e7c2ba1"},"kdf":"scrypt","kdfparams":{"dklen":32,"n":262144,"p":1,"r":8,"salt":"1f3f814262b9a4ce3c2f3e1cabb5788f0520101f00598aa0b84bbda08ceaaf31"},"mac":"8e8393e86fe2278666ec26e9956b49adc25bc2e7492d5a25ee30e8118dd17441"},"id":"71aa2bfd-ee91-4206-ab5e-82c38ccd071f","version":3}/`
- The account is on your vm too: `sudo ls /var/lib/docker/volumes/devchain_geth/_data/devchain`. From here you can save or import another account

If needed, create new account with:
- Create password: `echo "Geneva2017" > /root/.ethereum/devchain/pw2`
- create account: `geth --datadir=/root/.ethereum/devchain account new --password /root/.ethereum/devchain/pw2`

- Don't want to mine? In `docker-compose.yml` section `geth/command` remove `--fast --mine` and run again `docker-compose up -d`
- Check that you are well connected to our netstat dashboard: http://factory.shinit.net:15000
- Use python to check your node, and later send ether: `python3 checkWeb3.py`

## Truffle
- Go in truffle container:  `docker exec -it truffle sh`
- try truffle:
```
cd /usr/src/app
truffle init
vi truffle.js
  host:"testrpc" <-- edit this line
  port: 8545     <-- edit this line

truffle test
```
- And same test with `host:geth port 8540` --> if warning: `authentication needed: password or unlock` --> you need to unlock your wallet!

Now test our helloWord dapp
- Navigate to the folder: `cd /dapp/helloWorld`
- Test the contract against the testrpc mode: `truffle test --testrpc`
- Test against our devchain node: `truffle test --devchain`
