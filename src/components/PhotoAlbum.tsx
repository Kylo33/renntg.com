import { RowsPhotoAlbum } from "react-photo-album";
import "react-photo-album/rows.css";

interface Photo {
  src: string;
  width: number;
  height: number;
}

export default function PhotoGallery({ photos }: { photos: Photo[] }) {
  return (
    <RowsPhotoAlbum
      photos={photos}
      render={{
        image: (props) => <img {...props} className="rounded-xl shadow-md" />,
      }}
    />
  );
}
