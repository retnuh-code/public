import { useParams, Navigate } from 'react-router-dom';

export default function Reader() {
  const { filename } = useParams();

  if (!filename) return <p>Invalid book file.</p>;

  return <Navigate to={`/readium/index.html?epub=/api/read/${filename}`} />;
}
