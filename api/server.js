// server.js
import app from './app.js';

const port = process.env.PORT || 1000;

// Start the server
app.listen(port, () => {
  console.log(`Server is running on http://localhost:${port}`);
});