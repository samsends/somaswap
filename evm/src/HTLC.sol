// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract HTLC {
    struct Lock {
        address receiver;
        address refundee;
        bytes32 hash;
        uint expiry;
        uint amount;
    }
    
    mapping(uint => Lock) public locks;
    uint public nonce;

    function create(address receiver, address refundee, bytes32 hash, uint expiry) external payable returns (uint id) {
        require(expiry > block.timestamp);
        locks[nonce] = Lock(receiver, refundee, hash, expiry, msg.value);
        id = nonce++;
    }

    function claim(uint id, bytes32 preimage) external {
        Lock memory lock = locks[id];
        require(keccak256(abi.encodePacked(preimage)) == lock.hash);
        require(block.timestamp < lock.expiry);
        delete locks[id];
        payable(lock.receiver).transfer(lock.amount);
    }

    function refund(uint id) external {
        Lock memory lock = locks[id];
        require(block.timestamp >= lock.expiry);
        delete locks[id];
        payable(lock.refundee).transfer(lock.amount);
    }
}
