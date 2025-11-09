import { ColumnsPhotoAlbum } from "react-photo-album";
import "react-photo-album/columns.css";

interface Photo {
  src: string;
  width: number;
  height: number;
}

export default function PhotoGallery({ photos }: { photos: Photo[] }) {
  return (
    <ColumnsPhotoAlbum
      photos={photos}
      render={{
        image: (props) => <img {...props} className="rounded-xl shadow-md" />,
      }}
    />
  );
}
