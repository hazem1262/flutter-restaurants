// To parse this JSON data, do
//
//     final restaurants = restaurantsFromJson(jsonString);

import 'dart:convert';

import 'dart:core';


Restaurants restaurantsFromJson(String str) => Restaurants.fromJson(json.decode(str));

String restaurantsToJson(Restaurants data) => json.encode(data.toJson());

class Restaurants {
  Results results;
  Search search;

  Restaurants({
    this.results,
    this.search,
  });

  factory Restaurants.fromJson(Map<String, dynamic> json) => new Restaurants(
    results: Results.fromJson(json["results"]),
    search: Search.fromJson(json["search"]),
  );

  Map<String, dynamic> toJson() => {
    "results": results.toJson(),
    "search": search.toJson(),
  };
}

class Results {
  String next;
  List<Item> items;

  Results({
    this.next,
    this.items,
  });

  factory Results.fromJson(Map<String, dynamic> json) => new Results(
    next: json["next"]??null,
    items: new List<Item>.from(json["items"].map((x) => Item.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "next": next,
    "items": new List<dynamic>.from(items.map((x) => x.toJson())),
  };
}

class Item extends Comparable{
  List<double> position;
  int distance;
  String title;
  dynamic averageRating;
  Category category;
  String icon;
  String vicinity;
  List<dynamic> having;
  ItemType type;
  String href;
  List<Tag> tags;
  String id;
  OpeningHours openingHours;
  List<AlternativeName> alternativeNames;
  bool isFav;
  bool tobeRated;
  String totalRating;
  String firebaseRating;

  Item({
    this.position,
    this.distance,
    this.title,
    this.averageRating,
    this.category,
    this.icon,
    this.vicinity,
    this.having,
    this.type,
    this.href,
    this.tags,
    this.id,
    this.openingHours,
    this.alternativeNames,
    this.isFav = false,
    this.tobeRated = false,
    this.totalRating = "",
    this.firebaseRating = ""

  });

  factory Item.fromJson(Map<String, dynamic> json) => new Item(
    position: new List<double>.from(json["position"].map((x) => x.toDouble())),
    distance: json["distance"],
    title: json["title"],
    averageRating: json["averageRating"],
    category: Category.fromJson(json["category"]),
    icon: json["icon"],
    vicinity: json["vicinity"],
    having: new List<dynamic>.from(json["having"].map((x) => x)),
    type: itemTypeValues.map[json["type"]],
    href: json["href"],
    tags: json["tags"] == null ? null : new List<Tag>.from(json["tags"].map((x) => Tag.fromJson(x))),
    id: json["id"],
    openingHours: json["openingHours"] == null ? null : OpeningHours.fromJson(json["openingHours"]),
    alternativeNames: json["alternativeNames"] == null ? null : new List<AlternativeName>.from(json["alternativeNames"].map((x) => AlternativeName.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "position": new List<dynamic>.from(position.map((x) => x)),
    "distance": distance,
    "title": title,
    "averageRating": averageRating,
    "category": category.toJson(),
    "icon": icon,
    "vicinity": vicinity,
    "having": new List<dynamic>.from(having.map((x) => x)),
    "type": itemTypeValues.reverse[type],
    "href": href,
    "tags": tags == null ? null : new List<dynamic>.from(tags.map((x) => x.toJson())),
    "id": id,
    "openingHours": openingHours == null ? null : openingHours.toJson(),
    "alternativeNames": alternativeNames == null ? null : new List<dynamic>.from(alternativeNames.map((x) => x.toJson())),
  };

  @override
  int compareTo(other) {

    return double.parse(this.totalRating) > double.parse((other as Item).totalRating) ? -1 : 1;
  }
}

class AlternativeName {
  String name;
  Language language;

  AlternativeName({
    this.name,
    this.language,
  });

  factory AlternativeName.fromJson(Map<String, dynamic> json) => new AlternativeName(
    name: json["name"],
    language: languageValues.map[json["language"]],
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "language": languageValues.reverse[language],
  };
}

enum Language { EN, DE }

final languageValues = new EnumValues({
  "de": Language.DE,
  "en": Language.EN
});

class Category {
  Id id;
  Title title;
  String href;
  CategoryType type;
  System system;

  Category({
    this.id,
    this.title,
    this.href,
    this.type,
    this.system,
  });

  factory Category.fromJson(Map<String, dynamic> json) => new Category(
    id: idValues.map[json["id"]],
    title: titleValues.map[json["title"]],
    href: json["href"],
    type: categoryTypeValues.map[json["type"]],
    system: systemValues.map[json["system"]],
  );

  Map<String, dynamic> toJson() => {
    "id": idValues.reverse[id],
    "title": titleValues.reverse[title],
    "href": href,
    "type": categoryTypeValues.reverse[type],
    "system": systemValues.reverse[system],
  };
}

enum Id { RESTAURANT, BAR_PUB }

final idValues = new EnumValues({
  "bar-pub": Id.BAR_PUB,
  "restaurant": Id.RESTAURANT
});

enum System { PLACES }

final systemValues = new EnumValues({
  "places": System.PLACES
});

enum Title { RESTAURANT, BAR_PUB }

final titleValues = new EnumValues({
  "Bar/Pub": Title.BAR_PUB,
  "Restaurant": Title.RESTAURANT
});

enum CategoryType { URN_NLP_TYPES_CATEGORY }

final categoryTypeValues = new EnumValues({
  "urn:nlp-types:category": CategoryType.URN_NLP_TYPES_CATEGORY
});

class OpeningHours {
  String text;
  Label label;
  bool isOpen;
  List<Structured> structured;

  OpeningHours({
    this.text,
    this.label,
    this.isOpen,
    this.structured,
  });

  factory OpeningHours.fromJson(Map<String, dynamic> json) => new OpeningHours(
    text: json["text"],
    label: labelValues.map[json["label"]],
    isOpen: json["isOpen"],
    structured: new List<Structured>.from(json["structured"].map((x) => Structured.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "text": text,
    "label": labelValues.reverse[label],
    "isOpen": isOpen,
    "structured": new List<dynamic>.from(structured.map((x) => x.toJson())),
  };
}

enum Label { OPENING_HOURS }

final labelValues = new EnumValues({
  "Opening hours": Label.OPENING_HOURS
});

class Structured {
  String start;
  String duration;
  String recurrence;

  Structured({
    this.start,
    this.duration,
    this.recurrence,
  });

  factory Structured.fromJson(Map<String, dynamic> json) => new Structured(
    start: json["start"],
    duration: json["duration"],
    recurrence: json["recurrence"],
  );

  Map<String, dynamic> toJson() => {
    "start": start,
    "duration": duration,
    "recurrence": recurrence,
  };
}

class Tag {
  String id;
  String title;
  Group group;

  Tag({
    this.id,
    this.title,
    this.group,
  });

  factory Tag.fromJson(Map<String, dynamic> json) => new Tag(
    id: json["id"],
    title: json["title"],
    group: groupValues.map[json["group"]],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "group": groupValues.reverse[group],
  };
}

enum Group { CUISINE }

final groupValues = new EnumValues({
  "cuisine": Group.CUISINE
});

enum ItemType { URN_NLP_TYPES_PLACE }

final itemTypeValues = new EnumValues({
  "urn:nlp-types:place": ItemType.URN_NLP_TYPES_PLACE
});

class Search {
  Context context;
  bool supportsPanning;
  String ranking;

  Search({
    this.context,
    this.supportsPanning,
    this.ranking,
  });

  factory Search.fromJson(Map<String, dynamic> json) => new Search(
    context: Context.fromJson(json["context"]),
    supportsPanning: json["supportsPanning"],
    ranking: json["ranking"],
  );

  Map<String, dynamic> toJson() => {
    "context": context.toJson(),
    "supportsPanning": supportsPanning,
    "ranking": ranking,
  };
}

class Context {
  Location location;
  ItemType type;
  String href;

  Context({
    this.location,
    this.type,
    this.href,
  });

  factory Context.fromJson(Map<String, dynamic> json) => new Context(
    location: Location.fromJson(json["location"]),
    type: itemTypeValues.map[json["type"]],
    href: json["href"],
  );

  Map<String, dynamic> toJson() => {
    "location": location.toJson(),
    "type": itemTypeValues.reverse[type],
    "href": href,
  };
}

class Location {
  List<double> position;
  Address address;

  Location({
    this.position,
    this.address,
  });

  factory Location.fromJson(Map<String, dynamic> json) => new Location(
    position: new List<double>.from(json["position"].map((x) => x.toDouble())),
    address: Address.fromJson(json["address"]),
  );

  Map<String, dynamic> toJson() => {
    "position": new List<dynamic>.from(position.map((x) => x)),
    "address": address.toJson(),
  };
}

class Address {
  String text;
  String house;
  String street;
  String postalCode;
  String district;
  String city;
  String county;
  String stateCode;
  String country;
  String countryCode;

  Address({
    this.text,
    this.house,
    this.street,
    this.postalCode,
    this.district,
    this.city,
    this.county,
    this.stateCode,
    this.country,
    this.countryCode,
  });

  factory Address.fromJson(Map<String, dynamic> json) => new Address(
    text: json["text"],
    house: json["house"],
    street: json["street"],
    postalCode: json["postalCode"],
    district: json["district"],
    city: json["city"],
    county: json["county"],
    stateCode: json["stateCode"],
    country: json["country"],
    countryCode: json["countryCode"],
  );

  Map<String, dynamic> toJson() => {
    "text": text,
    "house": house,
    "street": street,
    "postalCode": postalCode,
    "district": district,
    "city": city,
    "county": county,
    "stateCode": stateCode,
    "country": country,
    "countryCode": countryCode,
  };
}

class EnumValues<T> {
  Map<String, T> map;
  Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    if (reverseMap == null) {
      reverseMap = map.map((k, v) => new MapEntry(v, k));
    }
    return reverseMap;
  }
}
