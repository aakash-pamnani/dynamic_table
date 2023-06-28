List<String> genderDropdown = ["Male", "Female"];

// [Name,uniqueId,BirthDate,gender,OtherInfo]
List<List<dynamic>> dummyData = [
  [
    "Aakash",
    "101",
    DateTime(2000, 2, 11),
    genderDropdown[0],
    "Some other info about Aakash"
  ],
  [
    "Rohit",
    "102",
    DateTime(2000, 8, 30),
    genderDropdown[0],
    "Some other info about Rohit"
  ],
  [
    "Umesh",
    "103",
    DateTime(2000, 11, 30),
    genderDropdown[0],
    "Some other info about Umesh"
  ],
  // 50 more items
  [
    "John",
    "104",
    DateTime(1998, 5, 15),
    genderDropdown[0],
    "Some other info about John"
  ],
  [
    "Emily",
    "105",
    DateTime(1997, 9, 22),
    genderDropdown[1],
    "Some other info about Emily"
  ],
  [
    "Michael",
    "106",
    DateTime(1999, 3, 4),
    genderDropdown[0],
    "Some other info about Michael"
  ],
  [
    "Sarah",
    "107",
    DateTime(2001, 1, 10),
    genderDropdown[1],
    "Some other info about Sarah"
  ],
  [
    "David",
    "108",
    DateTime(2002, 7, 18),
    genderDropdown[0],
    "Some other info about David"
  ],
  [
    "Jessica",
    "109",
    DateTime(1996, 12, 25),
    genderDropdown[1],
    "Some other info about Jessica"
  ],
  [
    "Andrew",
    "110",
    DateTime(1997, 6, 9),
    genderDropdown[0],
    "Some other info about Andrew"
  ],
  [
    "Samantha",
    "111",
    DateTime(1999, 4, 2),
    genderDropdown[1],
    "Some other info about Samantha"
  ],
  [
    "Matthew",
    "112",
    DateTime(2003, 9, 3),
    genderDropdown[0],
    "Some other info about Matthew"
  ],
  [
    "Olivia",
    "113",
    DateTime(1998, 11, 14),
    genderDropdown[1],
    "Some other info about Olivia"
  ],
  [
    "Daniel",
    "114",
    DateTime(1995, 7, 28),
    genderDropdown[0],
    "Some other info about Daniel"
  ],
  [
    "Emily",
    "115",
    DateTime(2000, 6, 20),
    genderDropdown[1],
    "Some other info about Emily"
  ],
  [
    "Ryan",
    "116",
    DateTime(1997, 4, 19),
    genderDropdown[0],
    "Some other info about Ryan"
  ],
  [
    "Sophia",
    "117",
    DateTime(1999, 10, 9),
    genderDropdown[1],
    "Some other info about Sophia"
  ],
  [
    "Jacob",
    "118",
    DateTime(2001, 3, 27),
    genderDropdown[0],
    "Some other info about Jacob"
  ],
  [
    "Isabella",
    "119",
    DateTime(2002, 8, 5),
    genderDropdown[1],
    "Some other info about Isabella"
  ],
  [
    "Ethan",
    "120",
    DateTime(1996, 1, 7),
    genderDropdown[0],
    "Some other info about Ethan"
  ],
  [
    "Emma",
    "121",
    DateTime(2000, 10, 12),
    genderDropdown[1],
    "Some other info about Emma"
  ],
  [
    "Joshua",
    "122",
    DateTime(1997, 11, 17),
    genderDropdown[0],
    "Some other info about Joshua"
  ],
  [
    "Ava",
    "123",
    DateTime(1999, 5, 29),
    genderDropdown[1],
    "Some other info about Ava"
  ],
  [
    "Andrew",
    "124",
    DateTime(1998, 8, 8),
    genderDropdown[0],
    "Some other info about Andrew"
  ],
  [
    "Mia",
    "125",
    DateTime(2001, 12, 1),
    genderDropdown[1],
    "Some other info about Mia"
  ],
  [
    "Christopher",
    "126",
    DateTime(2003, 2, 23),
    genderDropdown[0],
    "Some other info about Christopher"
  ],
  [
    "Abigail",
    "127",
    DateTime(1996, 9, 5),
    genderDropdown[1],
    "Some other info about Abigail"
  ],
  [
    "Matthew",
    "128",
    DateTime(1998, 2, 14),
    genderDropdown[0],
    "Some other info about Matthew"
  ],
  [
    "Charlotte",
    "129",
    DateTime(2000, 7, 16),
    genderDropdown[1],
    "Some other info about Charlotte"
  ],
  [
    "Nicholas",
    "130",
    DateTime(1997, 3, 11),
    genderDropdown[0],
    "Some other info about Nicholas"
  ],
  [
    "Grace",
    "131",
    DateTime(1999, 8, 9),
    genderDropdown[1],
    "Some other info about Grace"
  ],
  [
    "Daniel",
    "132",
    DateTime(2001, 11, 6),
    genderDropdown[0],
    "Some other info about Daniel"
  ],
  [
    "Chloe",
    "133",
    DateTime(2002, 6, 13),
    genderDropdown[1],
    "Some other info about Chloe"
  ],
  [
    "Christopher",
    "134",
    DateTime(1996, 4, 25),
    genderDropdown[0],
    "Some other info about Christopher"
  ],
  [
    "Lily",
    "135",
    DateTime(1998, 10, 30),
    genderDropdown[1],
    "Some other info about Lily"
  ],
  [
    "Andrew",
    "136",
    DateTime(2000, 1, 2),
    genderDropdown[0],
    "Some other info about Andrew"
  ],
  [
    "Zoe",
    "137",
    DateTime(2001, 4, 5),
    genderDropdown[1],
    "Some other info about Zoe"
  ],
  [
    "Joseph",
    "138",
    DateTime(1997, 8, 21),
    genderDropdown[0],
    "Some other info about Joseph"
  ],
  [
    "Madison",
    "139",
    DateTime(1999, 1, 19),
    genderDropdown[1],
    "Some other info about Madison"
  ],
  [
    "Alexander",
    "140",
    DateTime(2002, 3, 7),
    genderDropdown[0],
    "Some other info about Alexander"
  ],
  [
    "Avery",
    "141",
    DateTime(1996, 6, 14),
    genderDropdown[1],
    "Some other info about Avery"
  ],
  [
    "William",
    "142",
    DateTime(1998, 9, 27),
    genderDropdown[0],
    "Some other info about William"
  ],
  [
    "Scarlett",
    "143",
    DateTime(2000, 5, 23),
    genderDropdown[1],
    "Some other info about Scarlett"
  ],
  [
    "David",
    "144",
    DateTime(2003, 10, 8),
    genderDropdown[0],
    "Some other info about David"
  ],
  [
    "Victoria",
    "145",
    DateTime(1997, 12, 12),
    genderDropdown[1],
    "Some other info about Victoria"
  ],
  [
    "James",
    "146",
    DateTime(1999, 6, 28),
    genderDropdown[0],
    "Some other info about James"
  ],
  [
    "Elizabeth",
    "147",
    DateTime(2001, 9, 3),
    genderDropdown[1],
    "Some other info about Elizabeth"
  ],
  [
    "Benjamin",
    "148",
    DateTime(1996, 10, 31),
    genderDropdown[0],
    "Some other info about Benjamin"
  ],
  [
    "Audrey",
    "149",
    DateTime(1998, 3, 9),
    genderDropdown[1],
    "Some other info about Audrey"
  ],
  [
    "Samuel",
    "150",
    DateTime(2000, 8, 17),
    genderDropdown[0],
    "Some other info about Samuel"
  ],
];
