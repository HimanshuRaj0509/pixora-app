import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pixora/features/auth/domain/entities/app_user.dart';
import 'package:pixora/features/auth/presentation/components/my_text_field.dart';
import 'package:pixora/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:pixora/features/post/domain/entities/comment.dart';
import 'package:pixora/features/post/domain/entities/post.dart';
import 'package:pixora/features/post/presentation/components/comment_tile.dart';
import 'package:pixora/features/post/presentation/cubits/post_cubit.dart';
import 'package:pixora/features/post/presentation/cubits/post_states.dart';
import 'package:pixora/features/profile/domain/entities/profile_user.dart';
import 'package:pixora/features/profile/presentation/cubits/profile_cubit.dart';
import 'package:pixora/features/profile/presentation/pages/profile_page.dart';

class PostTile extends StatefulWidget {
  final Post post;
  final void Function()? onDeletePressed;

  const PostTile(
      {super.key, required this.post, required this.onDeletePressed});

  @override
  State<PostTile> createState() => _PostTileState();
}

class _PostTileState extends State<PostTile> {
  //cubits
  late final postCubit = context.read<PostCubit>();
  late final profileCubit = context.read<ProfileCubit>();

  bool isOwnPost = false;

  //current user
  AppUser? currentUser;

  // post user

  ProfileUser? postUser;

  //on startup

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    getCurrentUser();
    fetchPostUser();
  }

  void getCurrentUser() {
    final authCubit = context.read<AuthCubit>();
    currentUser = authCubit.currentUser;
    isOwnPost = widget.post.userId == currentUser!.uid;
  }

  Future<void> fetchPostUser() async {
    final fetchedUser = await profileCubit.getUserProfile(widget.post.userId);

    if (fetchedUser != null) {
      setState(() {
        postUser = fetchedUser;
      });
    }
  }

  /*
  LIKES

  */

  //user tapped like button
  void toggleLikePost() {
    //current like status
    final isLiked = widget.post.likes.contains(currentUser!.uid);

    //optimistically like and update the ui
    setState(() {
      if (isLiked) {
        widget.post.likes.remove(currentUser!.uid); //like
      } else {
        widget.post.likes.add(currentUser!.uid); //unlike
      }
    });

    //update like
    postCubit
        .toggleLikePost(widget.post.id, currentUser!.uid)
        .catchError((error) {
      //if theres an error revert back to original values
      setState(() {
        if (isLiked) {
          widget.post.likes.add(currentUser!.uid); //revert unlike
        } else {
          widget.post.likes.remove(currentUser!.uid); //revert like
        }
      });
    });
  }

/*

Comments

*/

//comment text controller
  final commentTextController = TextEditingController();

  //open comment box - > user wants to type a new comment
  void openNewCommentBox() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text("Add a new comment"),
              content: MyTextField(
                controller: commentTextController,
                hintText: "Type a comment",
                obscureText: false,
              ),
              actions: [
                //cancel button
                TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text("Cancel")),

                //save button
                TextButton(
                    onPressed: () {
                      addComment();
                      Navigator.of(context).pop();
                    },
                    child: const Text("Save"))
              ],
            ));
  }

  void addComment() {
    //create a new comment
    final newComment = Comment(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        postId: widget.post.id,
        userId: currentUser!.uid,
        userName: currentUser!.name,
        text: commentTextController.text,
        timestamp: DateTime.now());

    //add comment using cubit
    if (commentTextController.text.isNotEmpty) {
      postCubit.addComment(widget.post.id, newComment);
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    commentTextController.dispose();
    super.dispose();
  }

  // show options for deletion
  void showOptions() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text("Delete Post?"),
              actions: [
                //cancel button
                TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text("Cancel")),

                //delete button
                TextButton(
                    onPressed: () {
                      widget.onDeletePressed!();
                      Navigator.of(context).pop();
                    },
                    child: const Text("Delete")),
              ],
            ));
  }

  //BUILD UI
  // ... (keep all your imports and other code above)

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.secondary,
      child: Column(
        children: [
          // Top section: profile picture/name/delete button
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProfilePage(uid: widget.post.userId),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // profile pic
                  postUser?.profileImageUrl != null
                      ? CachedNetworkImage(
                          imageUrl: postUser!.profileImageUrl,
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.person),
                          imageBuilder: (context, imageProvider) => Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                image: imageProvider,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        )
                      : const Icon(Icons.person),
                  const SizedBox(width: 10),
                  // name
                  Text(
                    widget.post.userName,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.inversePrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  // delete button
                  if (isOwnPost)
                    GestureDetector(
                      onTap: showOptions,
                      child: Icon(
                        Icons.delete,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Post image
          CachedNetworkImage(
            imageUrl: widget.post.imageUrl,
            height: 430,
            width: double.infinity,
            fit: BoxFit.cover,
            placeholder: (context, url) => const SizedBox(height: 430),
            errorWidget: (context, url, error) => const Icon(Icons.error),
          ),

          // Buttons: like, comment, timestamp
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                SizedBox(
                  width: 50,
                  child: Row(
                    children: [
                      // like button
                      GestureDetector(
                        onTap: toggleLikePost,
                        child: Icon(
                          widget.post.likes.contains(currentUser!.uid)
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: widget.post.likes.contains(currentUser!.uid)
                              ? Colors.red
                              : Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 5),
                      // like count
                      Text(
                        widget.post.likes.length.toString(),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                // comment button
                GestureDetector(
                  onTap: openNewCommentBox,
                  child: Icon(
                    Icons.comment,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  widget.post.comments.length.toString(),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 12,
                  ),
                ),
                const Spacer(),
                // timestamp
                Text(widget.post.timestamp.toString()),
              ],
            ),
          ),

          // CAPTION
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20),
            child: Row(
              children: [
                // username
                Text(
                  widget.post.userName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 10),
                // text
                Text(widget.post.text),
              ],
            ),
          ),

          // COMMENT SECTION (only one instance)
          BlocBuilder<PostCubit, PostState>(
            builder: (context, state) {
              if (state is PostsLoaded) {
                final post = state.posts.firstWhere(
                  (post) => post.id == widget.post.id,
                  orElse: () => widget.post,
                );

                if (post.comments.isNotEmpty) {
                  return ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.3,
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: post.comments.length,
                      itemBuilder: (context, index) {
                        final comment = post.comments[index];
                        return CommentTile(comment: comment);
                      },
                    ),
                  );
                }
                return const SizedBox();
              }

              if (state is PostsLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is PostsError) {
                return Center(child: Text(state.message));
              }

              return const SizedBox();
            },
          ),
        ],
      ),
    );
  }
  // @override
  // Widget build(BuildContext context) {
  //   return Container(
  //     color: Theme.of(context).colorScheme.secondary,
  //     child: Column(
  //       children: [
  //         //Top section : profile picture/ name / delete button
  //         GestureDetector(
  //           onTap: ()=>Navigator.push(context,MaterialPageRoute(builder: (context)=>ProfilePage(uid: widget.post.userId))),
  //           child: Padding(
  //             padding: const EdgeInsets.all(12.0),
  //             child: Row(
  //               mainAxisAlignment: MainAxisAlignment.start,
  //               children: [
  //                 //profile pic
  //                 postUser?.profileImageUrl != null
  //                     ? CachedNetworkImage(
  //                         imageUrl: postUser!.profileImageUrl,
  //                         errorWidget: (context, url, error) =>
  //                             const Icon(Icons.person),
  //                         imageBuilder: (context, imageProvider) => Container(
  //                           width: 40,
  //                           height: 40,
  //                           decoration: BoxDecoration(
  //                               shape: BoxShape.circle,
  //                               image: DecorationImage(
  //                                   image: imageProvider, fit: BoxFit.cover)),
  //                         ),
  //                       )
  //                     : const Icon(Icons.person),

  //                 const SizedBox(
  //                   width: 10,
  //                 ),

  //                 //name
  //                 Text(
  //                   widget.post.userName,
  //                   style: TextStyle(
  //                     color: Theme.of(context).colorScheme.inversePrimary,
  //                     fontWeight: FontWeight.bold,
  //                   ),
  //                 ),

  //                 const Spacer(),

  //                 //delete button
  //                 if (isOwnPost)
  //                   GestureDetector(
  //                     onTap: showOptions,
  //                     child: Icon(Icons.delete,
  //                         color: Theme.of(context).colorScheme.primary),
  //                   )
  //               ],
  //             ),
  //           ),
  //         ),
  //         CachedNetworkImage(
  //           imageUrl: widget.post.imageUrl,
  //           height: 430,
  //           width: double.infinity,
  //           fit: BoxFit.cover,
  //           placeholder: (context, url) => const SizedBox(
  //             height: 430,
  //           ),
  //           errorWidget: (context, url, error) => const Icon(Icons.error),
  //         ),

  //         //buttons -> like, comment, timestamp
  //         Padding(
  //           padding: const EdgeInsets.all(20.0),
  //           child: Row(
  //             children: [
  //               SizedBox(
  //                 width: 50,
  //                 child: Row(
  //                   children: [
  //                     // like button
  //                     GestureDetector(
  //                         onTap: toggleLikePost,
  //                         child: Icon(
  //                           widget.post.likes.contains(currentUser!.uid)
  //                               ? Icons.favorite
  //                               : Icons.favorite_border,
  //                           color: widget.post.likes.contains(currentUser!.uid)
  //                               ? Colors.red
  //                               : Theme.of(context).colorScheme.primary,
  //                         )),

  //                     const SizedBox(
  //                       width: 5,
  //                     ),

  //                     //like count
  //                     Text(
  //                       widget.post.likes.length.toString(),
  //                       style: TextStyle(
  //                         color: Theme.of(context).colorScheme.primary,
  //                         fontSize: 12,
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //               const SizedBox(
  //                 width: 20,
  //               ),

  //               //comment button
  //               GestureDetector(
  //                   onTap: openNewCommentBox,
  //                   child: Icon(
  //                     Icons.comment,
  //                     color: Theme.of(context).colorScheme.primary,
  //                   )),

  //               const SizedBox(
  //                 width: 5,
  //               ),

  //               Text(
  //                 widget.post.comments.length.toString(),
  //                 style: TextStyle(
  //                   color: Theme.of(context).colorScheme.primary,
  //                   fontSize: 12,
  //                 ),
  //               ),

  //               const Spacer(),

  //               //timestamp
  //               Text(widget.post.timestamp.toString())
  //             ],
  //           ),
  //         ),

  //         //CAPTION
  //         Padding(
  //           padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20),
  //           child: Row(
  //             children: [
  //               //username
  //               Text(
  //                 widget.post.userName,
  //                 style: const TextStyle(fontWeight: FontWeight.bold),
  //               ),

  //               const SizedBox(
  //                 width: 10,
  //               ),

  //               //text
  //               Text(widget.post.text)
  //             ],
  //           ),
  //         ),

  //         //COMMENT SECTION
  //         BlocBuilder<PostCubit, PostState>(
  //           builder: (context, state) {
  //             //LOADED
  //             if (state is PostsLoaded) {
  //               //final individual post
  //               final post = state.posts
  //                   .firstWhere((post) => (post.id == widget.post.id));

  //               if (post.comments.isNotEmpty) {
  //                 //how many comments to show
  //                 int showCommentCount = post.comments.length;

  //                 //comment section
  //                 return ListView.builder(
  //                     itemCount: showCommentCount,
  //                     shrinkWrap: true,
  //                     physics: const NeverScrollableScrollPhysics(),
  //                     itemBuilder: (context, index) {
  //                       //get individual comment
  //                       final comment = post.comments[index];

  //                       //comment tile UI
  //                       return Padding(
  //                         padding: const EdgeInsets.only(left: 20.0),
  //                         child: Row(
  //                           children: [
  //                             //name
  //                             Text(comment.userName,
  //                                 style: TextStyle(
  //                                   fontWeight: FontWeight.bold,
  //                                 )),

  //                             const SizedBox(
  //                               width: 10,
  //                             ),

  //                             //comment text
  //                             Text(comment.text),

  //                             //
  //                           ],
  //                         ),
  //                       );
  //                     });
  //               }
  //             }

  //             //LOADING..
  //             if (state is PostsLoading) {
  //               return const Center(
  //                 child: CircularProgressIndicator(),
  //               );
  //             }

  //             //ERROR
  //             else if (state is PostsError) {
  //               return Center(
  //                 child: Text(state.message),
  //               );
  //             } else {
  //               return const SizedBox();
  //             }
  //           },
  //         ),

  //         //CAPTION
  //         Padding(
  //           padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20),
  //           child: Row(
  //             children: [
  //               //username
  //               Text(
  //                 widget.post.userName,
  //                 style: TextStyle(
  //                   fontWeight: FontWeight.bold,
  //                 ),
  //               ),

  //               const SizedBox(
  //                 width: 10,
  //               ),

  //               //text
  //               Text(widget.post.text),
  //             ],
  //           ),
  //         ),

  //         //COMMENT SECTION
  //         BlocBuilder<PostCubit, PostState>(builder: (context, state) {
  //           //LOADED

  //           if (state is PostsLoaded) {
  //             //final each post
  //             final post =
  //                 state.posts.firstWhere((post) => post.id == widget.post.id);

  //             if (post.comments.isNotEmpty) {
  //               //how many comments to show
  //               int showCommentCount = post.comments.length;

  //               //comment section
  //               return ListView.builder(
  //                   itemCount: showCommentCount,
  //                   itemBuilder: (context, index) {
  //                     //get individual comment
  //                     final comment = post.comments[index];

  //                     //comment tile UI
  //                     return CommentTile(comment: comment);
  //                   });
  //             }
  //           }

  //           //LOADING...
  //           if (state is PostsLoading) {
  //             return const Center(
  //               child: CircularProgressIndicator(),
  //             );
  //           }

  //           //ERROR
  //           else if (state is PostsError) {
  //             return Center(
  //               child: Text(state.message),
  //             );
  //           } else {
  //             return Center(
  //               child: Text("Something went wrong..."),
  //             );
  //           }
  //         })
  //       ],
  //     ),
  //   );
  // }
}
