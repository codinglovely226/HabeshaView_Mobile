import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:next_hour/apidata/apidata.dart';
import 'package:next_hour/global.dart';
import 'package:next_hour/ui/intro_slider.dart';
import 'package:next_hour/model/WatchlistModel.dart';
import 'package:next_hour/model/video_data.dart';
import 'package:next_hour/model/seasons.dart';
import 'package:next_hour/controller/navigation_bar_controller.dart';
import 'package:next_hour/ui/no_network.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(new MaterialApp(
  home: LoadingScreen(
  ),
));

class LoadingScreen extends StatefulWidget {
  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> with TickerProviderStateMixin {
  Animation<double> containerGrowAnimation;
  AnimationController _screenController;
  Animation<Color> fadeScreenAnimation;
  bool _visible = false;
  bool _visible2 = false;
  bool _visible3 = false;
  var _connectionStatus = 'Unknown';
  Connectivity connectivity;
  // ignore: cancel_subscriptions
  StreamSubscription<ConnectivityResult> subscription;
  // ignore: unused_field
  String _debugLabelString = "";
  // ignore: unused_field
  bool _enableConsentButton = false;
  bool _requireConsent = true;

  getValuesSF() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      boolValue = prefs.getBool('boolValue');
    });
  }

  @override
  void initState() {
    super.initState();
    this.getValuesSF();

//    connectivity = new Connectivity();
//    subscription =
//        connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
//          _connectionStatus = result.toString();
//          print(_connectionStatus);
//          if (result == ConnectivityResult.wifi ||
//              result == ConnectivityResult.mobile) {
            getApplicationDocumentsDirectory().then((Directory directory) {
              dir = directory;
              jsonFile = new File(dir.path + "/" + fileName);
              fileExists = jsonFile.existsSync();
              if (fileExists)
                this.setState(
                        () => fileContent = json.decode(jsonFile.readAsStringSync()));
            });

            Timer(Duration(seconds: 1), () {
              setState(() {
                _visible = true;
              });
            });

            Timer(Duration(seconds: 2), () {
              loginFromFIle();
            });
            Timer(Duration(seconds: 5), () {
              _visible3 = true;
            });

            initPlatformState();

//          } else {
////        NoNetwork();
//            var router = new MaterialPageRoute(
//                builder: (BuildContext context) => NoNetwork());
//            Navigator.of(context).push(router);
//          }
//        });
  }

  @override
  void dispose() {
    _screenController.dispose();
    super.dispose();
  }

//  This FUTURE is used to login automatically through file that already save email and password
  Future<String> loginFromFIle() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {

        final basicDetails = await http.get(
          Uri.encodeFull(APIData.homeDataApi),
        );
        homeApiResponseData = json.decode(basicDetails.body);
        setState(() {
          loginImageData = homeApiResponseData['login_img'];
          loginConfigData = homeApiResponseData['config'];
          homeDataBlocks = homeApiResponseData['blocks'];
          showPaymentGateway = homeApiResponseData['config'];
          blogResponse = homeApiResponseData['blogs'];
          donationUrl=showPaymentGateway['donation_link'];

        });
        setState(() {
          _visible2 = true;
        });
        if (fileExists) {
          final accessToken = await http.post(APIData.tokenApi, body: {
            "email": fileContent['user'],
            "password": fileContent['pass'],
          });
          var user = json.decode(accessToken.body);
          final response = await http.get(APIData.userProfileApi,
              headers: {
                // ignore: deprecated_member_use
                HttpHeaders.AUTHORIZATION: "Bearer ${user['access_token']}!"
              });

          final menuResponse =
          await http.get(Uri.encodeFull(APIData.topMenu), headers: {
            // ignore: deprecated_member_use
            HttpHeaders.AUTHORIZATION: "Bearer ${user['access_token']}!"

          });
          topMData = json.decode(menuResponse.body);
          print("1");
          final allMovieApiResponse = await http.get(Uri.encodeFull(APIData.allMovies), headers: {
            // ignore: deprecated_member_use
            HttpHeaders.AUTHORIZATION: "Bearer ${user['access_token']}!"

          });
          var allMovieDataResponse = json.decode(allMovieApiResponse.body);

          final sliderResponse =
          await http.get(Uri.encodeFull(APIData.sliderApi), headers: {
            // ignore: deprecated_member_use
            HttpHeaders.AUTHORIZATION: "Bearer ${user['access_token']}!"

          });
          print("2");

          final showWatchlistResponse =
          await http.get(Uri.encodeFull(APIData.watchListApi), headers: {
            // ignore: deprecated_member_use
            HttpHeaders.AUTHORIZATION: "Bearer ${user['access_token']}!"

          });
          var showWatchlistData = json.decode(showWatchlistResponse.body);

          sliderResponseData = json.decode(sliderResponse.body);
          sliderData = sliderResponseData['slider'];

          showWatchlist = showWatchlistData['wishlist'];

          setState(() {
            stripePayment=showPaymentGateway['stripe_payment'];
            btreePayment=showPaymentGateway['braintree'];
            paystackPayment=showPaymentGateway['paystack'];
            bankPayment=showPaymentGateway['bankdetails'];
            accountNo=showPaymentGateway['account_no'];
            branchName=showPaymentGateway['branch'];
            bankAccountName=showPaymentGateway['account_name'];
            bankIFSCCode=showPaymentGateway['ifsc_code'];
            bankName=showPaymentGateway['bank_name'];
            wEmail=showPaymentGateway['w_email'];
            blogStatus=showPaymentGateway['blog'];
            donationStatus=showPaymentGateway['donation'];
            fbLoginStatus=showPaymentGateway['fb_login'];
            videoCommentsStatus=showPaymentGateway['comments'];
          });

          final compData = await http
              .get(Uri.encodeFull(APIData.movieTvApi), headers: {
            // ignore: deprecated_member_use
            HttpHeaders.AUTHORIZATION: "Bearer ${user['access_token']}!"
          });
          var aData = json.decode(compData.body);
          List aData2 = aData['data'];
          final mainResponse2 =
          await http.get(Uri.encodeFull(APIData.allDataApi), headers: {
            // ignore: deprecated_member_use
            HttpHeaders.AUTHORIZATION: "Bearer ${user['access_token']}!"

          });

          final stripeDetailsResponse =
          await http.get(Uri.encodeFull(APIData.stripeDetailApi), headers: {
            // ignore: deprecated_member_use
            HttpHeaders.AUTHORIZATION: "Bearer ${user['access_token']}!"

          });
          stripeData = json.decode(stripeDetailsResponse.body);
          print(stripeData);
          if(stripeData != "error"){
            stripeKey = stripeData['key'];
            stripePass = stripeData['pass'];
            payStackKey = stripeData['paystack'];
          }

          final response2 = await http.get(
            Uri.encodeFull(APIData.faq),
          );

          faqApiData = json.decode(response2.body);
          print("Main Data: $faqApiData");
          faqHelp = faqApiData['faqs'];

          var mainData2 = json.decode(mainResponse2.body);
          var genreData2 = mainData2['genre'];
          print("aData $aData2");
          var dataLen = aData2.length == null ? 0 : aData2.length;
          searchIds2.clear();
          if (dataLen != null) {
            for (var all = 0; all < dataLen; all++) {
              searchIds2.add(aData2[all]);
            }
          }
          print("3");
          var singleId;

          userWatchListOld = List<VideoDataModel>.generate(searchIds2 == null ? 0 : dataLen,
                  (int index) {

                var type = searchIds2[index]['type'];

                var description = searchIds2[index]['detail'];

                var t = description;

                var genreIdbyM = searchIds2[index]['genre_id'];

                singleId = genreIdbyM.split(",");
                print("31");
                print("DataLen $dataLen");

                var tmdbrating =  searchIds2[index]['rating'] == null ? 0 : searchIds2[index]['rating'];
                double convrInStart = tmdbrating != null ? tmdbrating / 2 : 0;

                print("Index: $index");
                print("SearchId: $searchIds2");
                List<dynamic> se2;
                if (type == "T") {
                  se2 = searchIds2[index]['seasons'] as List<dynamic>;
                } else {
                  se2 = searchIds2[index]['movie_series'] as List<dynamic>;
                }
                print("SearchId2: ${searchIds2[index]}");

                return VideoDataModel(
                  id: searchIds2[index]['id'],
                  name: '${searchIds2[index]['title']}',
                  box: type == "T"
                      ? "${APIData.tvImageUriTv}" +
                      "${searchIds2[index]['thumbnail']}"
                      : "${APIData.movieImageUri}" +
                      "${searchIds2[index]['thumbnail']}",
                  cover: type == "T"
                      ? "${APIData.tvImageUriPosterTv}" +
                      "${searchIds2[index]['poster']}"
                      : "${APIData.movieImageUriPosterMovie}" +
                      "${searchIds2[index]['poster']}",
                  description: '$t',
                  datatype: type,
                  rating: convrInStart,
                  screenshots: List.generate(3, (int xyz) {
                    return type == "T"
                        ? "${APIData.tvImageUriPosterTv}" +
                        "${searchIds2[index]['poster']}"
                        : "${APIData.movieImageUriPosterMovie}" +
                        "${searchIds2[index]['poster']}";
                  }),
                  url: '${searchIds2[index]['trailer_url']}',
                  menuId: 1,
                  genre: List.generate(singleId == null ? 0 : singleId.length,
                          (int xyz) {
                        return "${singleId[xyz]}";
                      }),
                  genres: List.generate(genreData2 == null ? 0 : genreData2.length,
                          (int xyz) {
                        var genreId2 = genreData2[xyz]['id'].toString();
                        var zx = List.generate(singleId == null ? 0 : singleId.length,
                                (int xyz) {
                              return "${singleId[xyz]}";
                            });
                        var isAv2 = 0;
                        for (var y in zx) {
                          if (genreId2 == y) {
                            isAv2 = 1;
                            break;
                          }
                        }
                        if (isAv2 == 1) {
                          if (genreData2[xyz]['name'] == null) {
                            return null;
                          } else {
                            return "${genreData2[xyz]['name']}";
                          }
                        }
                        return null;
                      }),
                  seasons:
                  List<Seasons>.generate(se2 == null ? 0 : se2.length, (int s) {
                    if (type == "T") {
                      return new Seasons(
                        id: se2[s]['id'],
                        sTvSeriesId: se2[s]['tv_series_id'],
                        sSeasonNo: se2[s]['season_no'],
                        thumbnail: se2[s]['thumbnail'],
                        cover: se2[s]['poster'],
                        description: se2[s]['detail'],
                        sActorId: se2[s]['actor_id'],
                        language: se2[s]['a_language'],
                        type: se2[s]['type'],
                      );
                    } else {
                      return null;
                    }
                  }
                  ),
                  maturityRating: '${searchIds2[index]['maturity_rating']}',
                  duration: type == "T"
                      ? 'Not Available'
                      : '${searchIds2[index]['duration']}',
                  released: type == "T"
                      ? 'Not Available'
                      : '${searchIds2[index]['released']}',
                );
              });

          print("4jgjigi");
          userWatchList = List<WatchlistModel>.generate(
              showWatchlist == null ? 0 : showWatchlist.length, (int index) {
            print("seconfIndex ${showWatchlist[index]}");
            return showWatchlist[index]['season_id'] != null ? WatchlistModel(

              id: showWatchlist[index]['id'],
              wUserId: showWatchlist[index]['user_id'],

              season_id: showWatchlist[index]['season_id'],
              added: showWatchlist[index]['added'],
              wCreatedAt: '${showWatchlist[index]['created_at']}',
              wUpdatedAt: '${showWatchlist[index]['updated_at']}',
            ) :  new WatchlistModel(

              id: showWatchlist[index]['id'],
              wUserId: showWatchlist[index]['user_id'],
              wMovieId: showWatchlist[index]['movie_id'],
              added: showWatchlist[index]['added'],
              wCreatedAt: '${showWatchlist[index]['created_at']}',
              wUpdatedAt: '${showWatchlist[index]['updated_at']}',
            );
          });
          print("5");
          setState(() {
            loginConfigData = homeApiResponseData['config'];
            topMenuData = topMData['menu'];
            menuList = topMenuData.length;
            fullData = "Bearer ${user['access_token']}!";
            mDataCount = allMovieDataResponse['movie'];
            movieDataLength = mDataCount.length;
          });


          setState(() {
            print("1");
            dataUser = json.decode(response.body);
            print("2");
            userDetail = dataUser['user'];
            isAdmin = userDetail['is_admin'];
            userPaypalPayId = dataUser['payid'];
            userId = userDetail['id'];
            print("3");
            userName = userDetail['name'];
            userEmail = userDetail['email'];
            userMobile = userDetail['mobile'];
            userDOB = userDetail['dob'];
            print("4");
            userCreatedAt = userDetail['created_at'];

            stripeCustomerId = userDetail['stripe_id'];
            print("6");
            userActivePlan = dataUser['current_subscription'];
            userPaymentType = dataUser['payment'];
            userPaypalHistory = dataUser['paypal'];
            print("7");
            userStripeHistory = userDetail['subscriptions'];
            userExpiryDate = dataUser['end'];
            userImage = userDetail['image'];
            print("9");
            status = dataUser['active'];
            print("8");
            userPlanStart = dataUser['start'] != null ? DateTime.parse(dataUser['start']) : 'N/A';
            userPlanEnd = dataUser['end'] != null ? DateTime.parse(dataUser['end']) : 'N/A';
            currentDate = dataUser['current_date'] != null ? DateTime.parse(dataUser['current_date']) : 'N/A';
            faqHelp = faqApiData['faqs'];
            print("5");
          });


          setState(() {
            showWatchlist = showWatchlistData['wishlist'];
            userId = userDetail['id'];
            code = dataUser['code'];
            name = userName;
            nameInitial = userName[0];
            email = userEmail;
            expiryDate = userExpiryDate;
            activeStatus = userActiveStatus;
            userPaypalHistory = dataUser['paypal'];
            userStripeHistory = userDetail['subscriptions'];
            print("6");
            if (isAdmin == "1") {
              status = 1;
              userName = "Admin";
            } else {
              name = userName;
            }
            if (userMobile == null) {
              mobile = "N/A";
            } else {
              mobile = userMobile;
            }
            if (userDOB == null) {
              dob = 'N/A';
            } else {
              dob = userDOB;
            }
            if (userCreatedAt == null) {
              created_at = "";
            } else {
              created_at = userCreatedAt;
            }
            if (userActivePlan == null) {
              activePlan = "";
            } else {
              activePlan = userActivePlan;
            }
            if (userExpiryDate == null) {
              expiryDate = '';
            } else {
              expiryDate = userExpiryDate;
            }
            if (expiryDate == '' ||
                expiryDate == 'N/A' ||
                userExpiryDate == null ||
                status == 0) {
              difference = null;
            }
          });
          var router = new MaterialPageRoute(
              builder: (BuildContext context) =>
              new BottomNavigationBarController()
          );
          Navigator.of(context).push(router);

          return (accessToken.body);
        } else {
          if (homeDataBlocks != null) {
            var router = new MaterialPageRoute(
                builder: (BuildContext context) => new IntroScreen());
            Navigator.of(context).push(router);
          }
        }
      }

    } on HttpException catch (e1) {
      print("HttpException $e1");
      return null;
    }
    on FormatException catch (e2) {
      print("FormatException $e2");
      return null;
    }
    on SocketException catch (e3) {
      print("SocketException $e3");
      return null;
    }
    on Exception catch (e4) {
      print("Exception $e4");
      return null;
    }
    return (null);
  }

// One Signal In-app notification example
  oneSignalInAppMessagingTriggerExamples() async {
    OneSignal.shared.addTrigger("trigger_1", "one");

    Map<String, Object> triggers = new Map<String, Object>();
    triggers["trigger_2"] = "two";
    triggers["trigger_3"] = "three";
    OneSignal.shared.addTriggers(triggers);

    OneSignal.shared.removeTriggerForKey("trigger_2");

    // ignore: unused_local_variable
    Object triggerValue =
    await OneSignal.shared.getTriggerValueForKey("trigger_3");
    List<String> keys = new List<String>();
    keys.add("trigger_1");
    keys.add("trigger_3");
    OneSignal.shared.removeTriggersForKeys(keys);

    OneSignal.shared.pauseInAppMessages(false);
  }

// For One Signal permission
  void _handleConsent() {
    OneSignal.shared.consentGranted(true);
    this.setState(() {
      _enableConsentButton = false;
    });
  }

// For One Signal notification
  Future<void> initPlatformState() async {
    if (!mounted) return;
    OneSignal.shared.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);

    OneSignal.shared.setRequiresUserPrivacyConsent(_requireConsent);

    var settings = {
      OSiOSSettings.autoPrompt: false,
      OSiOSSettings.promptBeforeOpeningPushUrl: true
    };

    OneSignal.shared
        .setNotificationReceivedHandler((OSNotification notification) {
      this.setState(() {
        _debugLabelString =
        "Received notification: \n${notification.jsonRepresentation().replaceAll("\\n", "\n")}";
      });
    });

    OneSignal.shared
        .setNotificationOpenedHandler((OSNotificationOpenedResult result) {
      this.setState(() {
        _debugLabelString =
        "Opened notification: \n${result.notification.jsonRepresentation().replaceAll("\\n", "\n")}";
      });
    });

    OneSignal.shared
        .setInAppMessageClickedHandler((OSInAppMessageAction action) {
      this.setState(() {
        _debugLabelString =
        "In App Message Clicked: \n${action.jsonRepresentation().replaceAll("\\n", "\n")}";
      });
    });

    OneSignal.shared
        .setSubscriptionObserver((OSSubscriptionStateChanges changes) {
    });

    OneSignal.shared.setPermissionObserver((OSPermissionStateChanges changes) {
    });

    OneSignal.shared.setEmailSubscriptionObserver(
            (OSEmailSubscriptionStateChanges changes) {
        });

    await OneSignal.shared
        .init("c6a46559-2a32-42d4-bd24-e51f4339740f", iOSSettings: settings);

    OneSignal.shared
        .setInFocusDisplayType(OSNotificationDisplayType.notification);

    bool requiresConsent = await OneSignal.shared.requiresUserPrivacyConsent();

    this.setState(() {
      _enableConsentButton = requiresConsent;
    });
    oneSignalInAppMessagingTriggerExamples();
  }

  Widget loading(){
    return Expanded(
        child: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              animatedOpacityLogo(),
              Padding(padding: EdgeInsets.only(top: 20.0)),
              animatedOpacityCircular(),
            ],
          ),
        ));
  }

  Widget animatedOpacityLogo(){
    return AnimatedOpacity(
      opacity: _visible == true ? 1.0 : 0.0,
      duration: Duration(milliseconds: 500),
      child: loginConfigData == null
          ? SizedBox(
        height: 25.0,
      )
          : AnimatedOpacity(
        opacity: _visible2 == true ? 1.0 : 0.0,
        duration: Duration(milliseconds: 1000),
        child: new Image.network(
          '${APIData.logoImageUri}${loginConfigData['logo']}',
          scale: 1.8,
        ),
      ),
    );
  }

  Widget animatedOpacityCircular(){
    return AnimatedOpacity(
        opacity: _visible == true ? 1.0 : 0.0,
        duration: Duration(milliseconds: 500),
        child: _visible3 == true
            ? CircularProgressIndicator(
          valueColor: new AlwaysStoppedAnimation<Color>(
              Colors.red),
        )
            : CircularProgressIndicator(
          valueColor: new AlwaysStoppedAnimation<Color>(
              Colors.green),
        ));
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    _handleConsent();
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Container(
              decoration: BoxDecoration(
                color: primaryColor,
              )),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              loading(),
            ],
          )
        ],
      ),
    );
  }
}
