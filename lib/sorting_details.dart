import 'package:flutter/material.dart';
import 'constants.dart';
import 'widgets.dart';

class SortDetailsScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => SortDetailsScreenState();
}

class SortDetailsScreenState extends State<SortDetailsScreen> {
  List<int> numbers;
  List<int> pointers = [];
  int n;
  String updateText, selectedAlgorithm = sortingAlgorithmsList[0].title;
  bool disableButtons = false, isSelectingDelay = false, isCancelled = false;
  double _delay = 2;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    numbers = new List<int>.generate(10, (i) => i + 1);
    n = numbers.length;
    shuffle();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      body: Container(
        color: primary,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            AppBar(
              centerTitle: true,
              title: Text('Sorting Algorithms'),
              elevation: 0,
              backgroundColor: primary,
            ),
            SoringAlgorithmsList(
              isDisabled: disableButtons,
              onTap: (selected) {
                selectedAlgorithm = selected;
              },
            ),
            ChartWidget(
              numbers: numbers,
              activeElements: pointers,
            ),
            BottomPointer(
              length: numbers.length,
              pointers: pointers,
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Text(
                    updateText,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            bottomButtons(),
          ],
        ),
      ),
    );
  }

  Widget bottomButtons() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          FloatingActionButton.extended(
            heroTag: 'sort',
            backgroundColor: primaryDark,
            label: Text(disableButtons ? 'Cancel' : 'Sort'),
            icon: Icon(disableButtons ? Icons.stop : Icons.play_circle_outline),
            onPressed: () {
              if (disableButtons) {
                setState(() {
                  isCancelled = true;
                });
              } else {
                selectWhichSorting();
              }
            },
          ),
          FloatingActionButton.extended(
            heroTag: 'shuffle',
            backgroundColor: disableButtons ? Colors.black : primaryDark,
            label: Text('Shuffle'),
            icon: Icon(Icons.shuffle),
            onPressed: () => disableButtons ? null : shuffle(),
          ),
          // FloatingActionButton(
          //   heroTag: 'details',
          //   backgroundColor: primaryDark,
          //   child: Icon(Icons.info_outline),
          //   onPressed: () {
          //     showModalBottomSheet(
          //         context: context,
          //         builder: (BuildContext bc) {
          //           return Container(
          //             height: MediaQuery.of(context).size.height / 2,
          //             decoration: BoxDecoration(
          //                 color: primary,
          //                 borderRadius: BorderRadius.only(
          //                     topLeft: Radius.circular(8.0),
          //                     topRight: Radius.circular(8.0))),
          //           );
          //         });
          //   },
          // ),
        ],
      ),
    );
  }

  void selectWhichSorting() {
    switch (selectedAlgorithm) {
      case bubbleSortTitle:
        bubbleSort();
        break;
      case selectionSortTitle:
        selectionSort();
        break;
      case insertionSortTitle:
        insertionSort();
        break;
      default:
        break;
    }
  }

  void shuffle() {
    setState(() {
      updateText = 'Press the sort button to start sorting';
      numbers.shuffle();
    });
  }

  void updatePointers(List<int> currentPointers) {
    setState(() {
      pointers = currentPointers;
    });
  }

  void finishedSorting() {
    setState(() {
      updateText = 'Sorting Completed';
      disableButtons = false;
    });
  }

  void cancelledSorting() {
    setState(() {
      updateText = 'Sorting Cancelled';
      disableButtons = false;
    });
  }

  void startSorting() {
    setState(() {
      isCancelled = false;
      disableButtons = true;
      isSelectingDelay = false;
    });
  }

  void setUpdateText(String text) {
    setState(() {
      updateText = text;
    });
  }

  void swap(numbers, i, j) {
    int temp = numbers[i];
    numbers[i] = numbers[j];
    numbers[j] = temp;
  }

  //Bubble Sort
  void bubbleSort() async {
    startSorting();
    int i, step;
    for (step = 0; step < n; step++) {
      if (isCancelled) break;
      for (i = 0; i < n - step - 1; i++) {
        if (isCancelled) break;
        updatePointers([i, i + 1]);
        setUpdateText('Is ${numbers[i]} > ${numbers[i + 1]} ?');
        await Future.delayed(Duration(seconds: (_delay ~/ 2).toInt()));
        if (numbers[i] > numbers[i + 1]) {
          swap(numbers, i, i + 1);
          setUpdateText('Yes, so swapping.');
        } else {
          setUpdateText('No, so no need to swap.');
        }
        await Future.delayed(Duration(seconds: (_delay ~/ 2).toInt()));
      }
    }
    isCancelled ? cancelledSorting() : finishedSorting();
  }

  //SelectionSort
  void selectionSort() async {
    startSorting();
    // One by one move boundary of unsorted subnumbersay
    for (int i = 0; i < n - 1; i++) {
      if (isCancelled) break;
      // Find the minimum element in unsorted numbersay
      int minIdx = i;
      setUpdateText('Finding minimum');
      for (int j = i + 1; j < n; j++) {
        if (isCancelled) break;
        updatePointers([i, j]);
        await Future.delayed(Duration(milliseconds: 250));
        if (numbers[j] < numbers[minIdx]) minIdx = j;
      }

      // Swap the found minimum element with the first element
      updatePointers([minIdx, i]);
      setUpdateText(
          'Swapping minimum element ${numbers[minIdx]} and ${numbers[i]}');
      await Future.delayed(Duration(seconds: 1));
      swap(numbers, minIdx, i);
    }
    isCancelled ? cancelledSorting() : finishedSorting();
  }

  //Insertion Sort
  void insertionSort() async {
    startSorting();
    int i, key, j;
    updatePointers([0]);
    setUpdateText('Assume first element to be already sorted');
    await Future.delayed(Duration(seconds: 1));
    for (i = 1; i < n; i++) {
      if (isCancelled) break;
      updatePointers([i]);
      setUpdateText('Taking ${numbers[i]} as key element.');
      await Future.delayed(Duration(seconds: 1));
      key = numbers[i];
      j = i - 1;

      while (j >= 0 && numbers[j] > key) {
        updatePointers([numbers.indexOf(key), j]);
        setUpdateText(
            'Since $key < ${numbers[j]} so, inserting it one place before.');
        await Future.delayed(Duration(seconds: 1));

        swap(numbers, j + 1, j);
        updatePointers([numbers.indexOf(key)]);
        await Future.delayed(Duration(seconds: 1));
        j = j - 1;
      }
      numbers[j + 1] = key;
    }
    isCancelled ? cancelledSorting() : finishedSorting();
  }
}
