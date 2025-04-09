import fs from 'fs';
import pdfParse from 'pdf-parse';

/**
 * Reads and parses a PDF file for metadata and text
 * @param {string} filePath - Path to the PDF file
 * @returns {Promise<Object>} - Parsed PDF metadata and text
 */
export async function parsePDF(filePath) {
  try {
    const dataBuffer = fs.readFileSync(filePath);
    const data = await pdfParse(dataBuffer);
    return {
      title: data.info?.Title || 'Unknown',
      author: data.info?.Author || 'Unknown',
      text: data.text || ''
    };
  } catch (err) {
    console.error(`Error parsing PDF at ${filePath}:`, err.message);
    return {
      title: 'Error',
      author: 'Error',
      text: ''
    };
  }
}
