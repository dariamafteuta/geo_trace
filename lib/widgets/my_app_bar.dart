import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MyAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: const Padding(
        padding: EdgeInsets.only(left: 16),
        child: UndoRedoButtons(),
      ),
      leadingWidth: 125,
      actions: const [
        Padding(
          padding: EdgeInsets.only(right: 16),
          child: ActionButton(),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class ActionButton extends ConsumerWidget {
  const ActionButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSnapEnabled =
        ref.watch(drawingProvider2.select((state) => state.snapToGridEnabled));

    return CircleAvatar(
      backgroundColor: Colors.white,
      child: IconButton(
        icon: const Icon(Icons.grid_3x3_outlined),
        color: isSnapEnabled ? Colors.black : Colors.grey,
        onPressed: () {
          ref.read(drawingProvider2.notifier).toggleSnapToGrid();
        },
      ),
    );
  }
}

class UndoRedoButtons extends ConsumerWidget {
  const UndoRedoButtons({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            InkWell(
              onTap: () {
                ref.read(drawingProvider2.notifier).undo();
              },
              child: const Icon(
                CupertinoIcons.arrowshape_turn_up_left_fill,
                size: 24,
                color: Colors.grey,
              ),
            ),
            const Text(
              '|',
              style: TextStyle(color: Colors.grey),
            ),
            InkWell(
              onTap: () {
                ref.read(drawingProvider2.notifier).redo();
              },
              child: const Icon(
                CupertinoIcons.arrowshape_turn_up_right_fill,
                size: 24,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
