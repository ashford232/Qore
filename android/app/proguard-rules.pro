# --- ML Kit (ignore optional language models) ---
-dontwarn com.google.mlkit.vision.text.chinese.**
-dontwarn com.google.mlkit.vision.text.japanese.**
-dontwarn com.google.mlkit.vision.text.korean.**
-dontwarn com.google.mlkit.vision.text.devanagari.**

# --- PDF JP2 decoder ---
-dontwarn com.gemalto.jp2.**

# --- Keep ML Kit ---
-keep class com.google.mlkit.** { *; }

# --- Keep PDFBox ---
-keep class com.tom_roush.pdfbox.** { *; }