#!/bin/bash

# address 
# admin 0xa2fd4b7d45d18a58cb3714a26b70905980a6ceb1
# user1 0x15d7b4c55f177267f699857a9fef5e4a7d263f13
# user2 0xc360f7dc52a0ccec3974a3d955195c3a866c47f5
./invoke.sh "Admin" "getBalance" "\"0xa2fd4b7d45d18a58cb3714a26b70905980a6ceb1\"" # admin address

./invoke.sh "Admin" "getBalance" "\"0x15d7b4c55f177267f699857a9fef5e4a7d263f13\""

./invoke.sh "Admin" "getBalance" "\"0xc360f7dc52a0ccec3974a3d955195c3a866c47f5\""

