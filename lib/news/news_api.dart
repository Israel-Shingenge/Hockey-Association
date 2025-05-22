import 'package:flutter/material.dart';
import 'package:hockey_union/home/home_drawer.dart'; // Assuming you have a HomeDrawer
import 'package:http/http.dart' as http;

class News {
    List<NewsModel> news= [];




Future<void>getNews() async {
    String url = "https://newsdata.io/api/1/latest?apikey=YOUR_API_KEY&q=namibian%20sports%20news";
    var response = await http.get(Uri.parse(url));
   
   var jsonData = jsonDecode(response.body);

   if (jsonData['status'] == 'ok') {
     jsonData['news'].forEach((element)) {
       if (element["title"] != null && element["content"] != null) {
         NewsModel newsModel = NewsModel(
          title: element["title"],
          content: element["content"],
          date: DateTime.parse(element["pubDate"]),
          imageUrl: element["image_url"],
          url: element["url"],
          author: element["author"],
          );
            news.add(newsModel);
      
      
      }
       
       
       
     }
   
    }
}

}
