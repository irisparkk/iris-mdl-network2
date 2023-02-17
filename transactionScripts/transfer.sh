#!/bin/bash

# address 
# admin 0xa2fd4b7d45d18a58cb3714a26b70905980a6ceb1
# user1 0x15d7b4c55f177267f699857a9fef5e4a7d263f13
# user2 0xc360f7dc52a0ccec3974a3d955195c3a866c47f5

# ./invoke.sh "Admin" "transfer" "\"0x15d7b4c55f177267f699857a9fef5e4a7d263f13\",\"500\""

# 관리자가 자기 자신에게 송금 -> 송금 차단
# ./invoke.sh "Admin" "transfer" "\"0xa2fd4b7d45d18a58cb3714a26b70905980a6ceb1\",\"500\""

# 계좌 내 금액보다 더 많은 금액을 송금하려고 시도함
./invoke.sh "User1" "transfer" "\"0x15d7b4c55f177267f699857a9fef5e4a7d263f13\",\"5000000000\""