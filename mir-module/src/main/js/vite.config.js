import { defineConfig } from 'vite';

export default defineConfig({
  build: {
    rollupOptions: {
      input: {
        "user": 'src/user.ts',
      },
      output: {
        entryFileNames: '[name].js',  // Jeder Entry Point bekommt eine eigene JavaScript-Datei
        chunkFileNames: '[name].[hash].js',  // Chunks werden mit Hashes benannt (falls vorhanden)
        assetFileNames: '[name].[ext]',  // Assets wie CSS, Bilder etc. bekommen ihren ursprünglichen Namen
        dir: 'dist',  // Alle Bundles werden im Verzeichnis 'dist' abgelegt
      },
    },
  },
});
