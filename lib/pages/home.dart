import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis_auth/googleapis_auth.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:googleapis/people/v1.dart';
import 'package:http/http.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final GoogleSignIn googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'https://www.googleapis.com/auth/contacts.readonly',
      'https://www.googleapis.com/auth/contacts',
    ],
  );

  GoogleSignInAccount? _account;

  @override
  void initState() {
    super.initState();
    _initialsignIn();
  }

  Future<void> _initialsignIn() async {
    try {
      GoogleSignInAccount? account = await googleSignIn.signIn();
      setState(() {
        _account = account; // Update state when sign-in is complete
      });
    } catch (e) {
      print('Error during Google Sign-In: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text(
        "Synkify",
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
      )),
      body: Column(
        children: [
          Container(
            margin: EdgeInsets.all(12),
            //height: 50,
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Google",
                  style: TextStyle(fontSize: 14),
                ),
                // condition for alternatives
                _account == null
                    ? Container(
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                          color: Color.fromARGB(81, 111, 176, 209),
                        ),
                        padding: EdgeInsets.all(12),
                        width: double.infinity,
                        child: Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Not signed in to Google",
                                  style: TextStyle(fontSize: 18),
                                ),
                                TextButton(
                                    onPressed: () {
                                      handleSignIn();
                                    },
                                    child: const Text("Click Here to Sign In"))
                              ],
                            ),
                          ],
                        ))
                    : Container(
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                          color: Color.fromARGB(81, 111, 176, 209),
                        ),
                        padding: EdgeInsets.all(12),
                        width: double.infinity,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Signed in",
                                  style: TextStyle(fontSize: 18),
                                ),
                                Text(_account!.email)
                              ],
                            ),
                            const Icon(
                              Icons.check,
                              size: 28,
                              color: Colors.green,
                            ),
                          ],
                        ),
                      ),
              ],
            ),
          ),
          // ElevatedButton(
          //     onPressed: () {
          //       handleSignIn();
          //     },
          //     child: const Text("Google Sign In")),
          ElevatedButton(
              onPressed: () {
                handleGetContacts();
              },
              child: const Text("Get Contacts"))
        ],
      ),
    );
  }

  handleSignIn() {
    Future<GoogleSignInAccount?> acc = signInWithGoogle();
    print(acc);
  }

  handleGetContacts() {
    Future<String?> accessToken = getAccessToken();
    getGoogleContacts();
  }

  Future<void> getGoogleContacts() async {
    GoogleSignInAccount? account = await googleSignIn.signIn();
    try {
      if (account == null) {
        print("Sign-in failed or was canceled.");
        return;
      }

      final authToken = await account.authentication;
      final credentials = auth.AccessCredentials(
        auth.AccessToken(
          'Bearer',
          authToken.accessToken!,
          DateTime.now().add(Duration(hours: 1)).toUtc(),
        ),
        authToken.idToken,
        ['https://www.googleapis.com/auth/contacts.readonly'],
      );

      // Fetch and print contacts
      final contacts = await fetchGoogleContacts(credentials);
      print(contacts.length);
    } catch (e) {
      print('Error during Google Sign-In or contacts fetch: $e');
    }
  }

  Future<List<Person>> fetchGoogleContacts(
      auth.AccessCredentials credentials) async {
    final auth.AuthClient client =
        auth.authenticatedClient(Client(), credentials);

    try {
      final peopleApi = PeopleServiceApi(client);
      final response = await peopleApi.people.connections.list('people/me',
          personFields: 'names,emailAddresses,phoneNumbers',
          pageSize: 500 //change to fetchhh moreeeeeee
          );

      return response.connections ?? [];
    } catch (e) {
      print('Error fetching Google contacts: $e');
      return [];
    } finally {
      client.close();
    }
  }

  Future<GoogleSignInAccount?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? account = await googleSignIn.signIn();
      return account;
    } catch (error) {
      print("Google Sign-In error: $error");
      return null;
    }
  }

  Future<String?> getAccessToken() async {
    final GoogleSignInAuthentication auth =
        await googleSignIn.currentUser!.authentication;
    return auth.accessToken;
  }
}
