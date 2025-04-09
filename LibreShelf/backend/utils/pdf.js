import fs from 'fs';
import pdfParse from 'pdf-parse';

/**
 * Extract metadata and text from a PDF file
 * @param {string} filePath - Full path to the PDF file
 * @returns {Promise<Object>} - Parsed PDF metadata and text
 */
export async function parsePDF(filePath) {
  const dataBuffer = fs.readFileSync(filePath);
  const data = await pdfParse(dataBuffer);
  return {
    title: data.info.Title || 'Unknown',
    author: data.info.Author || 'Unknown',
    text: data.text || ''
  };
}
