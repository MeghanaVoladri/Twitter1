# Proj4

Twitter Clone

Submitted By:
Sreenivasa Sai Bhasanth Lakkaraju – 41602287 – slakkaraju@ufl.edu
Meghana Reddy Voladri – 43614999 – mvoladri@ufl.edu

## Approach

We have created a Twitter clone with one driver program, a client and a server. Client acts as a user and Server handles all the client requests including registration, distribution of tweets, retweeting, etc.
 
Following functionalities have been implemented as a part of Project 4.1:
1.	Register and delete account.
2.	Send tweet. We have created random tweets (using alphanumeric characters) with hashtags (#) and mentions (@).
3.	User can subscribe to tweets.
4.	A user can re-tweet another user’s tweet.
5.	Function to query and fetch tweets with specific hashtags, user mentions, etc.
6.	Live display of all the tweets if the user is still connected.

All the above functionalities have been properly tested and testcases have been written.

We have also implemented the bonus part where we have simulated the live connection and disconnection of users. This is being done by capturing the percentage of clients to be disconnected as a parameter from the user. Also, as and when the number of subscribers increase, number of tweets have been increased using the Zipf distribution. We have written the code to get the number of subscribers using the Zipf distribution function.

Project and bonus are in the same file LakkarajuVoladri.zip

## Run Instructions

To run the project, 
1.	To start process without disconnection, 
mix run main.exs <numUsers> <numMsgs>

2.	To start process with disconnection, 
mix run main.exs <numUsers> <numMsgs> <disconnectClients>

numUsers:  number of users to be created.
numMsgs: number of tweets a user must make
disconnectClients: percentage of users to be disconnected inorder to simulate live connection and disconnection process (bonus part)

3. To test the project,
mix test

This will execute all the test cases. All the testcases have passed with 0 failures