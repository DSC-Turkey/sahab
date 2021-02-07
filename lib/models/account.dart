import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class Account {
  String userId;
  List<dynamic> notificationUids;
  String emailAddress;
  String password;
  String nameAndSurname;
  String age;
  String job;
  String instagram;
  String twitter;
  String linkedIn;
  String phoneNumber;
  String avatar;
  String geoHash;
  GeoPoint geoPoint;
  int commentCount;
  bool isBanned;
  bool isDeleted;
  bool isFrozed;
  Timestamp creationDate;
  Timestamp deletionDate;
  Account({
    this.userId,
    this.notificationUids,
    this.emailAddress,
    this.password,
    this.nameAndSurname,
    this.age,
    this.job,
    this.instagram,
    this.twitter,
    this.linkedIn,
    this.phoneNumber,
    this.avatar,
    this.geoHash,
    this.geoPoint,
    this.commentCount,
    this.isBanned,
    this.isDeleted,
    this.isFrozed,
    this.creationDate,
    this.deletionDate,
  });

  Account copyWith({
    String userId,
    List<dynamic> notificationUids,
    String emailAddress,
    String password,
    String nameAndSurname,
    String age,
    String job,
    String instagram,
    String twitter,
    String linkedIn,
    String phoneNumber,
    String avatar,
    String geoHash,
    GeoPoint geoPoint,
    int commentCount,
    bool isBanned,
    bool isDeleted,
    bool isFrozed,
    Timestamp creationDate,
    Timestamp deletionDate,
  }) {
    return Account(
      userId: userId ?? this.userId,
      notificationUids: notificationUids ?? this.notificationUids,
      emailAddress: emailAddress ?? this.emailAddress,
      password: password ?? this.password,
      nameAndSurname: nameAndSurname ?? this.nameAndSurname,
      age: age ?? this.age,
      job: job ?? this.job,
      instagram: instagram ?? this.instagram,
      twitter: twitter ?? this.twitter,
      linkedIn: linkedIn ?? this.linkedIn,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      avatar: avatar ?? this.avatar,
      geoHash: geoHash ?? this.geoHash,
      geoPoint: geoPoint ?? this.geoPoint,
      commentCount: commentCount ?? this.commentCount,
      isBanned: isBanned ?? this.isBanned,
      isDeleted: isDeleted ?? this.isDeleted,
      isFrozed: isFrozed ?? this.isFrozed,
      creationDate: creationDate ?? this.creationDate,
      deletionDate: deletionDate ?? this.deletionDate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'notificationUids': notificationUids,
      'emailAddress': emailAddress,
      'password': password,
      'nameAndSurname': nameAndSurname,
      'age': age,
      'job': job,
      'instagram': instagram,
      'twitter': twitter,
      'linkedIn': linkedIn,
      'phoneNumber': phoneNumber,
      'avatar': avatar,
      'geoHash': geoHash,
      'geoPoint': geoPoint,
      'commentCount': commentCount,
      'isBanned': isBanned,
      'isDeleted': isDeleted,
      'isFrozed': isFrozed,
      'creationDate': creationDate,
      'deletionDate': deletionDate,
    };
  }

  factory Account.fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return Account(
      userId: map['userId'],
      notificationUids: map['notificationUids'],
      emailAddress: map['emailAddress'],
      password: map['password'],
      nameAndSurname: map['nameAndSurname'],
      age: map['age'],
      job: map['job'],
      instagram: map['instagram'],
      twitter: map['twitter'],
      linkedIn: map['linkedIn'],
      phoneNumber: map['phoneNumber'],
      avatar: map['avatar'],
      geoHash: map['geoHash'],
      geoPoint: map['geoPoint'],
      commentCount: map['commentCount'],
      isBanned: map['isBanned'],
      isDeleted: map['isDeleted'],
      isFrozed: map['isFrozed'],
      creationDate: map['creationDate'],
      deletionDate: map['deletionDate'],
    );
  }

  String toJson() => json.encode(toMap());

  factory Account.fromJson(String source) =>
      Account.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Account(userId: $userId, notificationUids: $notificationUids, emailAddress: $emailAddress, password: $password, nameAndSurname: $nameAndSurname, age: $age, job: $job, instagram: $instagram, twitter: $twitter, linkedIn: $linkedIn, phoneNumber: $phoneNumber, avatar: $avatar, geoHash: $geoHash, geoPoint: $geoPoint, commentCount: $commentCount, isBanned: $isBanned, isDeleted: $isDeleted, isFrozed: $isFrozed, creationDate: $creationDate, deletionDate: $deletionDate)';
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is Account &&
        o.userId == userId &&
        listEquals(o.notificationUids, notificationUids) &&
        o.emailAddress == emailAddress &&
        o.password == password &&
        o.nameAndSurname == nameAndSurname &&
        o.age == age &&
        o.job == job &&
        o.instagram == instagram &&
        o.twitter == twitter &&
        o.linkedIn == linkedIn &&
        o.phoneNumber == phoneNumber &&
        o.avatar == avatar &&
        o.geoHash == geoHash &&
        o.geoPoint == geoPoint &&
        o.commentCount == commentCount &&
        o.isBanned == isBanned &&
        o.isDeleted == isDeleted &&
        o.isFrozed == isFrozed &&
        o.creationDate == creationDate &&
        o.deletionDate == deletionDate;
  }

  @override
  int get hashCode {
    return userId.hashCode ^
        notificationUids.hashCode ^
        emailAddress.hashCode ^
        password.hashCode ^
        nameAndSurname.hashCode ^
        age.hashCode ^
        job.hashCode ^
        instagram.hashCode ^
        twitter.hashCode ^
        linkedIn.hashCode ^
        phoneNumber.hashCode ^
        avatar.hashCode ^
        geoHash.hashCode ^
        geoPoint.hashCode ^
        commentCount.hashCode ^
        isBanned.hashCode ^
        isDeleted.hashCode ^
        isFrozed.hashCode ^
        creationDate.hashCode ^
        deletionDate.hashCode;
  }
}
