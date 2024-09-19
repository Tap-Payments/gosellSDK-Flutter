extension StringCasingExtension on String {
  String toTitleCase() {
    return this.split(' ').map((word) =>
    word[0].toUpperCase() + word.substring(1).toLowerCase()
    ).join(' ');
  }
}

void main() {
  String text = "hello flutter devs!";
  print(text.toTitleCase()); // Outputs: Hello Flutter Devs!
}
