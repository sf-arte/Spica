# coding: utf-8
require 'sinatra'

get '/rest/' do
    '{ "photos": { "page": 1, "pages": "1", "perpage": 3, "total": "3",
        "photo": [
               { "id": "1111111111",
                 "owner": "222222222@N22",
                 "secret": "1a2b3c4d5",
                 "server": "1234",
                 "farm": 1,
                 "title": "hoge1",
                 "ownername": "hoge",
                 "latitude": 35.681382,
                 "longitude": 139.766084,
                 "url_o": "https:\/\/farm6.staticflickr.com\/5819\/30423578985_bb26300a4c_z_d.jpg",
                 "url_sq": "https:\/\/farm6.staticflickr.com\/5819\/30423578985_bb26300a4c_s.jpg"
               },
               { "id": "1111111111",
                 "owner": "222222222@N22",
                 "secret": "1a2b3c4d5",
                 "server": "1234",
                 "farm": 1,
                 "title": "hoge2",
                 "ownername": "hoge",
                 "latitude": 35.641382,
                 "longitude": 139.746084,
                 "url_o": "https:\/\/farm6.staticflickr.com\/5819\/30423578985_bb26300a4c_z_d.jpg",
                 "url_sq": "https:\/\/farm6.staticflickr.com\/5819\/30423578985_bb26300a4c_s.jpg"
               },
               { "id": "1111111111",
                 "owner": "222222222@N22",
                 "secret": "1a2b3c4d5",
                 "server": "1234",
                 "farm": 1,
                 "title": "hoge3",
                 "ownername": "hoge",
                 "latitude": 35.701382,
                 "longitude": 139.766084,
                 "url_o": "https:\/\/farm6.staticflickr.com\/5819\/30423578985_bb26300a4c_z_d.jpg",
                 "url_sq": "https:\/\/farm6.staticflickr.com\/5819\/30423578985_bb26300a4c_s.jpg"
               }
                 ]
            },
           "stat": "ok" }'
end
