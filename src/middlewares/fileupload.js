import multer from 'multer';

const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    req.body.userId = req.userObj.userId;
    cb(null, 'public/profilePhotos');
  },
  filename: (req, file, cb) => {
    cb(null, `${file.fieldname}-${req.body.userId}.${file.originalname.split('.')[file.originalname.split('.').length -1]}`)
  }
});

const uploadImage =  multer({ storage: storage });

const handleUploadedImage = (req, res, next) => {
  const file = req.file;
  if (!file) {
    const error = new Error('Please upload a file');
  }
  req.body.profilePhoto = `${file.path}`;
  return next()
}

export default uploadImage;
export { handleUploadedImage }
