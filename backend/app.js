require("dotenv").config();
const express = require("express");
const app = express();
const cors = require("cors");
const axios = require("axios");
const { GoogleGenerativeAI } = require("@google/generative-ai");
const { LanguageServiceClient } = require("@google-cloud/language");

app.use(cors());
app.use(express.json());

const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);
const imageUrlToBase64 = async (url) => {
  const response = await axios.get(url, { responseType: "arraybuffer" });
  return Buffer.from(response.data, "binary").toString("base64");
};

const analyzeImages = async (imageUrls) => {
  try {
    const model = genAI.getGenerativeModel({ model: "gemini-1.5-flash" });

    const results = await Promise.all(
      imageUrls.map(async (imageUrl) => {
        const imageBase64 = await imageUrlToBase64(imageUrl);

        const prompt = `You are a food quality evaluation expert.
                        Look at the image of food and return only a number between 0 to 10 indicating the quality of the food:
                        - 0 = extremely poor (spoiled, moldy, unhygienic)
                        - 10 = excellent (fresh, clean, healthy, ready to eat)
                        Respond with ONLY the number. No words.`;

        const result = await model.generateContent({
          contents: [
            {
              role: "user",
              parts: [
                { text: prompt },
                {
                  inlineData: {
                    mimeType: "image/jpeg",
                    data: imageBase64,
                  },
                },
              ],
            },
          ],
        });

        const raw = result.response.text().trim();
        const parsedScore = parseFloat(raw);
        const score = isNaN(parsedScore) ? null : Math.min(10, Math.max(0, parsedScore));

        return {
          imageUrl,
          qualityScore: score !== null ? score.toFixed(2) : "Not available",
        };
      })
    );

    return results;
  } catch (error) {
    console.error("Error analyzing images with Gemini:", error.message);
    throw new Error("Gemini image analysis failed");
  }
};

app.post("/analyze-food", async (req, res) => {
  const { imageUrls } = req.body;

  if (!Array.isArray(imageUrls) || imageUrls.length === 0) {
    return res.status(400).json({ error: "No image URLs provided" });
  }

  try {
    const results = await analyzeImages(imageUrls);
    res.json({ assessment: results });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

const feedbackclient = new LanguageServiceClient({
  keyFilename: "service-account.json",
});

const analyzeSentiment = async (text) => {
  try {
    const document = { content: text, type: "PLAIN_TEXT" };
    const [result] = await feedbackclient.analyzeSentiment({ document });
    return result.documentSentiment.score; 
  } catch (error) {
    console.error("Error analyzing sentiment:", error);
    return 0;  
  }
};


app.post("/analyze-feedback", async (req, res) => {
  const { feedbacks } = req.body;

  if (!Array.isArray(feedbacks)) {
    return res.status(400).json({ error: "Invalid input. Expected an array of strings." });
  }

  try {

    const results = await Promise.all(
      feedbacks.map(async (feedback) => ({
        text: feedback,
        score: await analyzeSentiment(feedback),
      }))
    );


    results.sort((a, b) => b.score - a.score);

    const averageScore =
      results.reduce((sum, item) => sum + item.score, 0) / results.length;

    res.json({ sortedFeedbacks: results, averageScore: averageScore.toFixed(2) });
  } catch (error) {
    res.status(500).json({ error: "Error processing feedback" });
  }
});

const port = process.env.PORT || 8080;

app.listen(port,()=>{
  console.log(`running on port ${port}`);
});