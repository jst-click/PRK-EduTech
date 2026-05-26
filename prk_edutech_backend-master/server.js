// index.js - Complete Node.js backend for user management system
require('dotenv').config();
const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const multer = require('multer');
const { CloudinaryStorage } = require('multer-storage-cloudinary');
const cloudinary = require('cloudinary').v2;
const { body, validationResult } = require('express-validator');

// Initialize Express app
const app = express();
const PORT = process.env.PORT || 5000;
const JWT_SECRET = process.env.JWT_SECRET || 'your_jwt_secret_key';
const ADMIN_EMAIL = (process.env.ADMIN_EMAIL || '').trim().toLowerCase();
const ADMIN_PASSWORD = process.env.ADMIN_PASSWORD || '';

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Print failed route responses with route + message for easier debugging
app.use((req, res, next) => {
  let responseBody;
  const originalJson = res.json.bind(res);

  res.json = (body) => {
    responseBody = body;
    return originalJson(body);
  };

  res.on('finish', () => {
    if (res.statusCode < 400) return;

    const route = req.originalUrl || req.url || 'unknown-route';
    const method = req.method || 'UNKNOWN';
    const errorMessage =
      responseBody?.message ||
      responseBody?.error ||
      (typeof responseBody === 'string' ? responseBody : 'No response message');

    console.error(`[ROUTE_ERROR] ${method} ${route} -> ${res.statusCode}: ${errorMessage}`);
  });

  next();
});

// MongoDB Connection
mongoose.connect(process.env.MONGODB_URI || 'mongodb+srv://aksmlibts:amit@cluster0.vqusi.mongodb.net/?retryWrites=true&w=majority', {
  useNewUrlParser: true,
  useUnifiedTopology: true,
})
.then(() => console.log('Connected to MongoDB'))
.catch(err => console.error('MongoDB connection error:', err));

// Configure Cloudinary for file uploads
cloudinary.config({
  cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
  api_key: process.env.CLOUDINARY_API_KEY,
  api_secret: process.env.CLOUDINARY_API_SECRET
});

const storage = new CloudinaryStorage({
  cloudinary: cloudinary,
  params: {
    folder: 'user-uploads',
    allowed_formats: ['jpg', 'jpeg', 'png', 'pdf']
  }
});

const upload = multer({ storage: storage });

const multiUpload = upload.fields([
  { name: 'thumbnail', maxCount: 1 }, 
  { name: 'pdf', maxCount: 1 }
]);

// Mongoose Schema Definitions
const testSchema = new mongoose.Schema({
  title: { type: String, required: true },
  topic: { type: String, required: true }, // New field
  description: { type: String, required: true }, // New field
  duration: { type: Number, required: true },
  questions: [
    {
      questionText: { type: String, required: true },
      options: {
        option1: { type: String, required: true },
        option2: { type: String, required: true },
        option3: { type: String, required: true },
        option4: { type: String, required: true }
      },
      correctOption: { type: String, enum: ['option1', 'option2', 'option3', 'option4'], required: true },
      solution: { type: String, required: true } // New field
    }
  ]
});

const validateTest = (req, res, next) => {
  const { title, topic, description, duration, questions } = req.body;

  if (!title || title.trim() === '') return res.status(400).json({ message: 'Title is required' });
  if (!topic || topic.trim() === '') return res.status(400).json({ message: 'Topic is required' });
  if (!description || description.trim() === '') return res.status(400).json({ message: 'Description is required' });
  if (!duration || duration <= 0) return res.status(400).json({ message: 'Invalid duration' });

  if (!questions || !Array.isArray(questions) || questions.length === 0) {
    return res.status(400).json({ message: 'At least one question is required' });
  }

  for (let question of questions) {
    if (!question.questionText || question.questionText.trim() === '') {
      return res.status(400).json({ message: 'Question text is required' });
    }

    if (!question.options || 
        !question.options.option1 || 
        !question.options.option2 || 
        !question.options.option3 || 
        !question.options.option4) {
      return res.status(400).json({ message: 'All options are required' });
    }

    if (!question.correctOption || !['option1', 'option2', 'option3', 'option4'].includes(question.correctOption)) {
      return res.status(400).json({ message: 'Invalid correct option' });
    }

    if (!question.solution || question.solution.trim() === '') {
      return res.status(400).json({ message: 'Solution is required' });
    }
  }

  next();
};
// User Schema
const userSchema = new mongoose.Schema({
  name: { type: String, required: true, trim: true },
  phone: { type: String, required: true },
  email: { type: String, required: true, unique: true, lowercase: true },
  password: { type: String, required: true },
  userType: { type: String, enum: ['free', 'admin', 'premium'], default: 'free' },
  profile: {
    photo: { type: String },
    about: { type: String },
    rollNumber: { type: String },
    dateOfJoining: { type: Date },
    parents: [{
      name: { type: String },
      relationship: { type: String },  // Add relationship field
      phone: { type: String },
      email: { type: String }
    }],
    personalDetails: {
      dob: { type: Date },
      gender: { type: String },
      nationality: { type: String },
      bloodGroup: { type: String },
      aadharNumber: { type: String },
      aadharImage: { type: String },
      pan: { type: String },
      panImage: { type: String },
      signatureImage: { type: String }
    },
    address: {
      permanent: {
        address: { type: String },
        pin: { type: String }
      },
      corresponding: {
        address: { type: String },
        pin: { type: String }
      }
    },
    education: {
      college: {
        name: { type: String },
        marks: { type: Number },
        resultImage: { type: String }
      },
      school12th: {
        name: { type: String },
        marks: { type: Number },
        resultImage: { type: String }
      },
      school10th: {
        name: { type: String },
        marks: { type: Number },
        resultImage: { type: String }
      }
    }
  },
  batches: [{ 
    type: mongoose.Schema.Types.ObjectId, 
    ref: 'Batch' 
  }],
  courses: [{ 
    type: mongoose.Schema.Types.ObjectId, 
    ref: 'Course' 
  }],
  notifications: [{
    message: { type: String },
    date: { type: Date, default: Date.now },
    read: { type: Boolean, default: false }
  }],
  createdAt: { type: Date, default: Date.now }
});

// Batch Schema
const batchSchema = new mongoose.Schema({
  name: { type: String, required: true },
  batchId: { type: String, required: true, unique: true },
  description: { type: String },
  students: [{ 
    type: mongoose.Schema.Types.ObjectId, 
    ref: 'User' 
  }]
});

// Course Schema
const courseSchema = new mongoose.Schema({
  title: { 
    type: String, 
    required: true 
  },
  courseId: { 
    type: String, 
    required: true, 
    unique: true 
  },
  duration: { 
    type: String, 
    required: true 
  },
  instructorName: { 
    type: String, 
    required: true 
  },
  thumbnail: { 
    type: String 
  },
  language: { 
    type: String, 
    required: true 
  },
  access: { 
    type: String, 
    enum: ['online', 'offline', 'both'], 
    required: true 
  },
  startDate: { 
    type: Date, 
    required: true 
  },
  endDate: { 
    type: Date, 
    required: true 
  },
  about: { 
    type: String, 
    required: true 
  },
  keyFeatures: [{ 
    type: String 
  }],
  isFree: { 
    type: Boolean, 
    default: false 
  },
  price: { 
    type: Number, 
    default: 0 
  },
  totalEnrollments: { 
    type: Number, 
    default: 0 
  },
  difficulty: { 
    type: String, 
    enum: ['Beginner', 'Intermediate', 'Advanced'], 
    default: 'Beginner' 
  },
  topCourseEnabled: {
    type: Boolean,
    default: false,
  },
  createdBy: { 
    type: mongoose.Schema.Types.ObjectId, 
    ref: 'User' 
  },
  createdAt: { 
    type: Date, 
    default: Date.now 
  },
  updatedAt: { 
    type: Date, 
    default: Date.now 
  }
}, { 
  timestamps: true 
});

const parseBooleanFlag = (value, fallback = false) => {
  if (value === undefined || value === null || value === '') return fallback;
  if (typeof value === 'boolean') return value;
  const normalized = String(value).trim().toLowerCase();
  if (['true', '1', 'yes', 'enabled', 'active'].includes(normalized)) return true;
  if (['false', '0', 'no', 'disabled', 'inactive'].includes(normalized)) return false;
  return fallback;
};

// Pre-save hook to generate unique courseId if not provided
courseSchema.pre('save', async function(next) {
  if (!this.courseId) {
    const prefix = this.title.slice(0, 3).toUpperCase();
    const randomSuffix = Math.random().toString(36).substring(2, 7).toUpperCase();
    this.courseId = `${prefix}-${randomSuffix}`;
  }
  next();
});

// Course Item Schema
const courseItemSchema = new mongoose.Schema({
  name: { type: String, required: true },
  description: { type: String },
  image: { type: String },
  courseId: { 
    type: mongoose.Schema.Types.ObjectId, 
    ref: 'Course',
    required: true
  }
});

// // Test Performance Schema
// const testSchema = new mongoose.Schema({
//   userId: { 
//     type: mongoose.Schema.Types.ObjectId, 
//     ref: 'User',
//     required: true
//   },
//   batchId: { 
//     type: mongoose.Schema.Types.ObjectId, 
//     ref: 'Batch' 
//   },
//   courseId: { 
//     type: mongoose.Schema.Types.ObjectId, 
//     ref: 'Course' 
//   },
//   testType: { type: String, enum: ['batch', 'course'], required: true },
//   date: { type: Date, default: Date.now },
//   marks: { type: Number, required: true },
//   totalMarks: { type: Number, required: true },
//   description: { type: String }
// });

// Assignment Schema
const assignmentSchema = new mongoose.Schema({
  title: { type: String, required: true },
  description: { type: String },
  deadline: { type: Date, required: true },
  batchId: { 
    type: mongoose.Schema.Types.ObjectId, 
    ref: 'Batch' 
  },
  courseId: { 
    type: mongoose.Schema.Types.ObjectId, 
    ref: 'Course' 
  },
  submissions: [{
    userId: { 
      type: mongoose.Schema.Types.ObjectId, 
      ref: 'User',
      required: true
    },
    submissionDate: { type: Date, default: Date.now },
    submissionFile: { type: String },
    marks: { type: Number },
    feedback: { type: String }
  }]
});

// Payment Schema
const paymentSchema = new mongoose.Schema({
  userId: { 
    type: mongoose.Schema.Types.ObjectId, 
    ref: 'User',
    required: true
  },
  amount: { type: Number, required: true },
  type: { type: String, enum: ['deposit', 'withdraw'], required: true },
  status: { type: String, enum: ['pending', 'completed', 'failed'], default: 'pending' },
  description: { type: String },
  transactionId: { type: String },
  date: { type: Date, default: Date.now }
});

// UI Components Schema
const uiComponentSchema = new mongoose.Schema({
  type: { type: String, enum: ['home', 'navbar', 'sidebar'], required: true },
  name: { type: String, required: true },
  icon: { type: String },
  description: { type: String },
  tag: { type: String }, // For sidebar items
  order: { type: Number, default: 0 } // To maintain order of components
});

const carouselImageSchema = new mongoose.Schema({
  id: String,
  imageUrl: String
});

const iconSchema = new mongoose.Schema({
  id: String,
  image: String,
  label: String
});

const bookSchema = new mongoose.Schema(
  {
    bookName: { type: String, required: true, trim: true },
    author: { type: String, required: true, trim: true },
    description: { type: String, required: true, trim: true },
    contentType: { type: String, enum: ['ebook', 'notes'], default: 'ebook' },
    subject: { type: String, default: 'General', trim: true },
    difficultyLevel: {
      type: String,
      enum: ['beginner', 'intermediate', 'advanced', 'general'],
      default: 'general',
    },
    pricing: { type: String, enum: ['free', 'paid'], default: 'free' },
    thumbnail: { type: String, default: '' },
    pdf: { type: String, default: '' },
  },
  { timestamps: true }
);

const cmsSchema = new mongoose.Schema(
  {
    terms: { type: String, default: '' },
    privacy: { type: String, default: '' },
  },
  { timestamps: true }
);

const faqSchema = new mongoose.Schema(
  {
    question: { type: String, required: true, trim: true },
    answer: { type: String, required: true, trim: true },
  },
  { timestamps: true }
);

const currentAffairSchema = new mongoose.Schema(
  {
    question: { type: String, required: true, trim: true },
    answer: { type: String, required: true, trim: true },
    img: { type: String, default: '', trim: true },
    source: { type: String, default: '', trim: true },
    publishedAt: { type: Date, default: Date.now },
    isActive: { type: Boolean, default: true },
  },
  { timestamps: true }
);

const jobListingSchema = new mongoose.Schema(
  {
    title: { type: String, required: true, trim: true },
    organisationName: { type: String, required: true, trim: true },
    postName: { type: String, required: true, trim: true },
    noOfVacancies: { type: Number, required: true, min: 1 },
    qualificationNeeded: { type: String, required: true, trim: true },
    lastDateToApply: { type: Date, required: true },
    linkToApply: { type: String, required: true, trim: true },
    sector: { type: String, enum: ['govt', 'pvt'], required: true },
    isActive: { type: Boolean, default: true },
  },
  { timestamps: true }
);

const testimonialSchema = new mongoose.Schema(
  {
    name: { type: String, required: true, trim: true },
    designation: { type: String, default: '', trim: true },
    message: { type: String, required: true, trim: true },
    rating: { type: Number, default: 5, min: 1, max: 5 },
    isActive: { type: Boolean, default: true },
  },
  { timestamps: true }
);

const onlineClassSchema = new mongoose.Schema(
  {
    img: { type: String, default: '', trim: true },
    title: { type: String, required: true, trim: true },
    date: { type: String, required: true, trim: true },
    time: { type: String, required: true, trim: true },
    description: { type: String, required: true, trim: true },
    isActive: { type: Boolean, default: true },
  },
  { timestamps: true }
);

const youtubeLinkSchema = new mongoose.Schema(
  {
    title: { type: String, required: true, trim: true },
    link: { type: String, required: true, trim: true },
    description: { type: String, required: true, trim: true },
    isActive: { type: Boolean, default: true },
  },
  { timestamps: true }
);

const resumeSchema = new mongoose.Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
      index: true,
    },
    name: { type: String, required: true, trim: true },
    phone: { type: String, required: true, trim: true },
    address: { type: String, required: true, trim: true },
    email: { type: String, required: true, trim: true, lowercase: true },
    summary: { type: String, required: true, trim: true },
    education: [
      {
        degree: { type: String, required: true, trim: true },
        college: { type: String, required: true, trim: true },
        location: { type: String, required: true, trim: true },
        gpa: { type: String, default: '', trim: true },
        coursework: { type: String, default: '', trim: true },
        title: { type: String, default: '', trim: true },
      },
    ],
    experience: [
      {
        company: { type: String, required: true, trim: true },
        position: { type: String, required: true, trim: true },
        startDate: { type: String, required: true, trim: true },
        endDate: { type: String, default: '', trim: true },
        location: { type: String, default: '', trim: true },
        description: { type: String, default: '', trim: true },
      },
    ],
    skills: [{ type: String, trim: true }],
    hobbies: [{ type: String, trim: true }],
  },
  { timestamps: true }
);

// Create model

// Create Mongoose Models
const User = mongoose.model('User', userSchema);
const Batch = mongoose.model('Batch', batchSchema);
const Course = mongoose.model('Course', courseSchema);
const CourseItem = mongoose.model('CourseItem', courseItemSchema);
const Test = mongoose.model('Test', testSchema);
const Assignment = mongoose.model('Assignment', assignmentSchema);
const Payment = mongoose.model('Payment', paymentSchema);
const UIComponent = mongoose.model('UIComponent', uiComponentSchema);
const CarouselImage = mongoose.model('CarouselImage', carouselImageSchema);
const Icon = mongoose.model('Icon', iconSchema);
const Book = mongoose.model('Book', bookSchema);
const CMS = mongoose.model('CMS', cmsSchema);
const FAQ = mongoose.model('FAQ', faqSchema);
const CurrentAffair = mongoose.model('CurrentAffair', currentAffairSchema);
const JobListing = mongoose.model('JobListing', jobListingSchema);
const Testimonial = mongoose.model('Testimonial', testimonialSchema);
const OnlineClass = mongoose.model('OnlineClass', onlineClassSchema);
const YoutubeLink = mongoose.model('YoutubeLink', youtubeLinkSchema);
const Resume = mongoose.model('Resume', resumeSchema);

const ensureEnvAdminUser = async () => {
  if (!ADMIN_EMAIL || !ADMIN_PASSWORD) {
    throw new Error('ADMIN_EMAIL and ADMIN_PASSWORD must be set in .env');
  }

  let adminUser = await User.findOne({ email: ADMIN_EMAIL });
  const hashedPassword = await bcrypt.hash(ADMIN_PASSWORD, 10);

  if (!adminUser) {
    adminUser = new User({
      name: 'System Admin',
      phone: '0000000000',
      email: ADMIN_EMAIL,
      password: hashedPassword,
      userType: 'admin'
    });
    await adminUser.save();
    return adminUser;
  }

  let hasChanges = false;

  if (adminUser.userType !== 'admin') {
    adminUser.userType = 'admin';
    hasChanges = true;
  }

  const isPasswordMatch = await bcrypt.compare(ADMIN_PASSWORD, adminUser.password);
  if (!isPasswordMatch) {
    adminUser.password = hashedPassword;
    hasChanges = true;
  }

  if (hasChanges) {
    await adminUser.save();
  }

  return adminUser;
};

// Authentication Middleware
const authenticateToken = (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];
  
  if (!token) return res.status(401).json({ message: 'Access token required' });
  
  jwt.verify(token, JWT_SECRET, (err, user) => {
    if (err) return res.status(403).json({ message: 'Invalid or expired token' });
    req.user = user;
    next();
  });
};

// Routes

// Health Check
app.get('/', (req, res) => {
  res.json({ message: 'Server is running' });
});

// Authentication Routes

// Login from .env admin credentials
app.post('/api/admin/login', [
  body('email').isEmail().withMessage('Valid email is required'),
  body('password').notEmpty().withMessage('Password is required')
], async (req, res) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({ errors: errors.array() });
  }

  try {
    if (!ADMIN_EMAIL || !ADMIN_PASSWORD) {
      return res.status(500).json({ message: 'Admin credentials are not configured on server' });
    }

    const { email, password } = req.body;
    const normalizedEmail = String(email).trim().toLowerCase();

    if (normalizedEmail !== ADMIN_EMAIL || password !== ADMIN_PASSWORD) {
      return res.status(401).json({ message: 'Invalid admin credentials' });
    }

    const adminUser = await ensureEnvAdminUser();

    const token = jwt.sign(
      {
        userId: adminUser._id.toString(),
        email: adminUser.email,
        userType: 'admin',
        isAdmin: true
      },
      JWT_SECRET,
      { expiresIn: '24h' }
    );

    res.json({
      message: 'Admin login successful',
      token,
      user: {
        id: adminUser._id,
        name: adminUser.name,
        email: adminUser.email,
        userType: 'admin'
      }
    });
  } catch (error) {
    console.error('Admin login error:', error);
    res.status(500).json({ message: 'Server error during admin login' });
  }
});

app.get('/api/admin/profile', authenticateToken, async (req, res) => {
  if (!req.user?.isAdmin && req.user?.userType !== 'admin') {
    return res.status(403).json({ message: 'Admin access required' });
  }

  try {
    const adminUser = await User.findById(req.user.userId).select('name email userType');
    if (!adminUser) {
      return res.status(404).json({ message: 'Admin user not found' });
    }

    res.json({
      id: adminUser._id,
      name: adminUser.name,
      email: adminUser.email,
      userType: adminUser.userType
    });
  } catch (error) {
    console.error('Admin profile fetch error:', error);
    res.status(500).json({ message: 'Server error while fetching admin profile' });
  }
});

// Register a new user
app.post('/api/auth/signup', [
  body('name').notEmpty().withMessage('Name is required'),
  body('phone').notEmpty().withMessage('Phone number is required'),
  body('email').isEmail().withMessage('Valid email is required'),
  body('password').isLength({ min: 6 }).withMessage('Password must be at least 6 characters')
], async (req, res) => {
  // Check for validation errors
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({ errors: errors.array() });
  }

  try {
    const { name, phone, email, password, userType } = req.body;

    // Check if user already exists
    const existingUser = await User.findOne({ email });
    if (existingUser) {
      return res.status(400).json({ message: 'User with this email already exists' });
    }

    // Hash password
    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);

    // Create new user
    const newUser = new User({
      name,
      phone,
      email,
      password: hashedPassword,
      userType: userType || 'free'
    });

    await newUser.save();

    // Generate JWT token
    const token = jwt.sign(
      { userId: newUser._id, email: newUser.email }, 
      JWT_SECRET, 
      { expiresIn: '24h' }
    );

    res.status(201).json({
      message: 'User registered successfully',
      token,
      user: {
        id: newUser._id,
        name: newUser.name,
        email: newUser.email,
        userType: newUser.userType
      }
    });
    } catch (error) {
        console.error('Registration error:', error.message); // Log the specific error message
        console.error(error.stack); // Log the stack trace for more details
        res.status(500).json({ message: 'Server error during registration', error: error.message });
    }
});

// Login user
app.post('/api/auth/login', [
  body('email').isEmail().withMessage('Valid email is required'),
  body('password').notEmpty().withMessage('Password is required')
], async (req, res) => {
  // Check for validation errors
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({ errors: errors.array() });
  }

  try {
    const { email, password } = req.body;

    // Find user by email
    const user = await User.findOne({ email });
    if (!user) {
      return res.status(400).json({ message: 'Invalid credentials' });
    }

    // Check password
    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(400).json({ message: 'Invalid credentials' });
    }

    // Generate JWT token
    const token = jwt.sign(
      { userId: user._id, email: user.email }, 
      JWT_SECRET, 
      { expiresIn: '24h' }
    );

    res.json({
      message: 'Login successful',
      token,
      user: {
        id: user._id,
        name: user.name,
        email: user.email,
        userType: user.userType
      }
    });
  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({ message: 'Server error during login' });
  }
});

app.post('/api/users/:userId/reset-password', authenticateToken, async (req, res) => {
  try {
    const { userId } = req.params;
    
    // Find the user
    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    // Generate a temporary password
    const tempPassword = generateTemporaryPassword();
    
    // Hash the temporary password
    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(tempPassword, salt);

    // Update user's password
    user.password = hashedPassword;
    await user.save();

    // Send password reset email (implement email sending logic)
    await sendPasswordResetEmail(user.email, tempPassword);

    res.json({ message: 'Password reset successfully. A temporary password has been sent to the user\'s email.' });
  } catch (error) {
    console.error('Password reset error:', error);
    res.status(500).json({ message: 'Server error while resetting password' });
  }
});

app.post('/api/users/reset-password', authenticateToken, async (req, res) => {
  try {
    const { userId, newPassword } = req.body;
    
    // Find the user
    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    // Hash the new password
    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(newPassword, salt);

    // Update user's password
    user.password = hashedPassword;
    await user.save();

    // Log the password reset action
    console.log(`Password reset for user: ${user.email}`);

    res.json({ 
      message: 'Password reset successfully',
      userEmail: user.email 
    });
  } catch (error) {
    console.error('Password reset error:', error);
    res.status(500).json({ 
      message: 'Server error while resetting password',
      error: error.message 
    });
  }
});

// Delete user
app.delete('/api/users/:userId', authenticateToken, async (req, res) => {
  try {
    const { userId } = req.params;
    
    // Find and delete the user
    const deletedUser = await User.findByIdAndDelete(userId);
    
    if (!deletedUser) {
      return res.status(404).json({ message: 'User not found' });
    }

    res.json({ 
      message: 'User deleted successfully',
      deletedUser: {
        id: deletedUser._id,
        email: deletedUser.email
      }
    });
  } catch (error) {
    console.error('User deletion error:', error);
    res.status(500).json({ 
      message: 'Server error while deleting user',
      error: error.message 
    });
  }
});

app.get('/api/search/users', authenticateToken, async (req, res) => {
  try {
    const { query } = req.query;
    
    let users;
    if (!query || query.trim() === '') {
      // If no query, fetch all users
      users = await User.find()
        .select('name email phone userType')
        .limit(50);
    } else {
      // If query exists, perform search
      users = await User.find({
        $or: [
          { name: { $regex: query, $options: 'i' } },
          { email: { $regex: query, $options: 'i' } },
          { phone: { $regex: query, $options: 'i' } }
        ]
      }).select('name email phone userType')
        .limit(50);
    }
    
    res.json(users);
  } catch (error) {
    console.error('Error searching users:', error);
    res.status(500).json({ message: 'Server error while searching users' });
  }
});

app.post('/api/users/reset-default-password', authenticateToken, async (req, res) => {
  try {
    const { userId, defaultPassword } = req.body;
    
    // Find the user
    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    // Hash the default password
    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(defaultPassword, salt);

    // Update user's password
    user.password = hashedPassword;
    await user.save();

    // Optional: Log the password reset action
    console.log(`Password reset to default for user: ${user.email}`);

    res.json({ 
      message: 'Password reset to default successfully',
      userEmail: user.email 
    });
  } catch (error) {
    console.error('Default password reset error:', error);
    res.status(500).json({ 
      message: 'Server error while resetting password to default',
      error: error.message 
    });
  }
});

// Google/Facebook OAuth routes would be implemented here
// For brevity, we're focusing on email/password auth in this example

// User Profile Routes

// Get current user profile
app.get('/api/profile', authenticateToken, async (req, res) => {
  try {
    const user = await User.findById(req.user.userId)
      .select('-password')
      .populate('batches', 'name batchId')
      .populate('courses', 'name courseId');
    
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }
    
    res.json(user);
  } catch (error) {
    console.error('Error fetching profile:', error);
    res.status(500).json({ message: 'Server error while fetching profile' });
  }
});

// Update user profile
app.put('/api/profile', authenticateToken, async (req, res) => {
  try {
    const { name, phone, about, rollNumber } = req.body;
    
    // Find user and update basic info
    const user = await User.findById(req.user.userId);
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }
    
    // Update fields if provided
    if (name) user.name = name;
    if (phone) user.phone = phone;
    
    // Update profile fields if provided
    if (!user.profile) user.profile = {};
    if (about) user.profile.about = about;
    if (rollNumber) user.profile.rollNumber = rollNumber;
    
    await user.save();
    
    res.json({ 
      message: 'Profile updated successfully',
      user: {
        id: user._id,
        name: user.name,
        email: user.email,
        profile: user.profile
      }
    });
  } catch (error) {
    console.error('Error updating profile:', error);
    res.status(500).json({ message: 'Server error while updating profile' });
  }
});

// Update profile photo
app.post('/api/profile/photo', authenticateToken, upload.single('photo'), async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ message: 'No file uploaded' });
    }
    
    const user = await User.findById(req.user.userId);
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }
    
    if (!user.profile) user.profile = {};
    user.profile.photo = req.file.path;
    await user.save();
    
    res.json({ 
      message: 'Profile photo updated successfully',
      photoUrl: req.file.path
    });
  } catch (error) {
    console.error('Error updating profile photo:', error);
    res.status(500).json({ message: 'Server error while updating profile photo' });
  }
});

// app.post('/api/profile/parents', authenticateToken, async (req, res) => {
//     try {
//       const { parents } = req.body;
      
//       if (!Array.isArray(parents)) {
//         return res.status(400).json({ message: 'Parents must be an array' });
//       }
      
//       const user = await User.findById(req.user.userId);
//       if (!user) {
//         return res.status(404).json({ message: 'User not found' });
//       }
      
//       if (!user.profile) user.profile = {};
//       user.profile.parents = parents;
//       await user.save();
      
//       res.json({ 
//         message: 'Parents information updated successfully',
//         parents: user.profile.parents
//       });
//     } catch (error) {
//       console.error('Error updating parents info:', error);
//       res.status(500).json({ message: 'Server error while updating parents information' });
//     }
//   });

app.post('/api/profile/parents', authenticateToken, async (req, res) => {
    try {
      const { parents } = req.body;

      // Validate if 'parents' is an array
      if (!Array.isArray(parents)) {
        return res.status(400).json({ message: 'Parents must be an array' });
      }

      // Validate each parent object to ensure it has the necessary fields
      parents.forEach(parent => {
        if (!parent.name || !parent.relationship || !parent.phone || !parent.email) {
          throw new Error('Each parent must have name, relationship, phone, and email');
        }
      });

      // Find the user by the user ID from the token
      const user = await User.findById(req.user.userId);
      if (!user) {
        return res.status(404).json({ message: 'User not found' });
      }

      // If user has no profile, initialize it
      if (!user.profile) user.profile = {};

      // Update the parents' information with the full details
      user.profile.parents = parents.map(parent => ({
        name: parent.name,
        relationship: parent.relationship,
        phone: parent.phone,
        email: parent.email
      }));

      // Save the updated user document
      await user.save();

      // Respond with a success message and the updated parents' info
      res.json({ 
        message: 'Parents information updated successfully',
        parents: user.profile.parents
      });
    } catch (error) {
      console.error('Error updating parents info:', error);
      res.status(500).json({ message: 'Server error while updating parents information' });
    }
});
  
  // Update personal details
  app.put('/api/profile/personal', authenticateToken, async (req, res) => {
    try {
      const { dob, gender, nationality, bloodGroup, aadharNumber, pan } = req.body;
      
      const user = await User.findById(req.user.userId);
      if (!user) {
        return res.status(404).json({ message: 'User not found' });
      }
      
      if (!user.profile) user.profile = {};
      if (!user.profile.personalDetails) user.profile.personalDetails = {};
      
      const personalDetails = user.profile.personalDetails;
      if (dob) personalDetails.dob = new Date(dob);
      if (gender) personalDetails.gender = gender;
      if (nationality) personalDetails.nationality = nationality;
      if (bloodGroup) personalDetails.bloodGroup = bloodGroup;
      if (aadharNumber) personalDetails.aadharNumber = aadharNumber;
      if (pan) personalDetails.pan = pan;
      
      await user.save();
      
      res.json({ 
        message: 'Personal details updated successfully',
        personalDetails: user.profile.personalDetails
      });
    } catch (error) {
      console.error('Error updating personal details:', error);
      res.status(500).json({ message: 'Server error while updating personal details' });
    }
  });
  
  // Upload identity documents (Aadhar, PAN, Signature)
  app.post('/api/profile/documents', authenticateToken, upload.fields([
    { name: 'aadharImage', maxCount: 1 },
    { name: 'panImage', maxCount: 1 },
    { name: 'signatureImage', maxCount: 1 }
  ]), async (req, res) => {
    try {
      const user = await User.findById(req.user.userId);
      if (!user) {
        return res.status(404).json({ message: 'User not found' });
      }
      
      if (!user.profile) user.profile = {};
      if (!user.profile.personalDetails) user.profile.personalDetails = {};
      
      const personalDetails = user.profile.personalDetails;
      
      // Update document URLs if files were uploaded
      if (req.files.aadharImage) {
        personalDetails.aadharImage = req.files.aadharImage[0].path;
      }
      
      if (req.files.panImage) {
        personalDetails.panImage = req.files.panImage[0].path;
      }
      
      if (req.files.signatureImage) {
        personalDetails.signatureImage = req.files.signatureImage[0].path;
      }
      
      await user.save();
      
      res.json({ 
        message: 'Documents uploaded successfully',
        documents: {
          aadharImage: personalDetails.aadharImage,
          panImage: personalDetails.panImage,
          signatureImage: personalDetails.signatureImage
        }
      });
    } catch (error) {
      console.error('Error uploading documents:', error);
      res.status(500).json({ message: 'Server error while uploading documents' });
    }
  });
  
  // Update address information
  app.put('/api/profile/address', authenticateToken, async (req, res) => {
    try {
      const { permanent, corresponding } = req.body;
      
      const user = await User.findById(req.user.userId);
      if (!user) {
        return res.status(404).json({ message: 'User not found' });
      }
      
      if (!user.profile) user.profile = {};
      if (!user.profile.address) user.profile.address = { permanent: {}, corresponding: {} };
      
      // Update permanent address if provided
      if (permanent) {
        if (permanent.address) user.profile.address.permanent.address = permanent.address;
        if (permanent.pin) user.profile.address.permanent.pin = permanent.pin;
      }
      
      // Update corresponding address if provided
      if (corresponding) {
        if (corresponding.address) user.profile.address.corresponding.address = corresponding.address;
        if (corresponding.pin) user.profile.address.corresponding.pin = corresponding.pin;
      }
      
      await user.save();
      
      res.json({ 
        message: 'Address information updated successfully',
        address: user.profile.address
      });
    } catch (error) {
      console.error('Error updating address:', error);
      res.status(500).json({ message: 'Server error while updating address' });
    }
  });
  
  // Update educational details
  app.put('/api/profile/education', authenticateToken, async (req, res) => {
    try {
      const { college, school12th, school10th } = req.body;
      
      const user = await User.findById(req.user.userId);
      if (!user) {
        return res.status(404).json({ message: 'User not found' });
      }
      
      if (!user.profile) user.profile = {};
      if (!user.profile.education) user.profile.education = { college: {}, school12th: {}, school10th: {} };
      
      // Update college details if provided
      if (college) {
        if (college.name) user.profile.education.college.name = college.name;
        if (college.marks) user.profile.education.college.marks = college.marks;
      }
      
      // Update 12th details if provided
      if (school12th) {
        if (school12th.name) user.profile.education.school12th.name = school12th.name;
        if (school12th.marks) user.profile.education.school12th.marks = school12th.marks;
      }
      
      // Update 10th details if provided
      if (school10th) {
        if (school10th.name) user.profile.education.school10th.name = school10th.name;
        if (school10th.marks) user.profile.education.school10th.marks = school10th.marks;
      }
      
      await user.save();
      
      res.json({ 
        message: 'Educational details updated successfully',
        education: user.profile.education
      });
    } catch (error) {
      console.error('Error updating educational details:', error);
      res.status(500).json({ message: 'Server error while updating educational details' });
    }
  });
  
  // Upload educational documents
  app.post('/api/profile/education/documents', authenticateToken, upload.fields([
    { name: 'collegeResult', maxCount: 1 },
    { name: 'result12th', maxCount: 1 },
    { name: 'result10th', maxCount: 1 }
  ]), async (req, res) => {
    try {
      const user = await User.findById(req.user.userId);
      if (!user) {
        return res.status(404).json({ message: 'User not found' });
      }
      
      if (!user.profile) user.profile = {};
      if (!user.profile.education) user.profile.education = { college: {}, school12th: {}, school10th: {} };
      
      // Update education document URLs if files were uploaded
      if (req.files.collegeResult) {
        user.profile.education.college.resultImage = req.files.collegeResult[0].path;
      }
      
      if (req.files.result12th) {
        user.profile.education.school12th.resultImage = req.files.result12th[0].path;
      }
      
      if (req.files.result10th) {
        user.profile.education.school10th.resultImage = req.files.result10th[0].path;
      }
      
      await user.save();
      
      res.json({ 
        message: 'Education documents uploaded successfully',
        documents: {
          collegeResult: user.profile.education.college.resultImage,
          result12th: user.profile.education.school12th.resultImage,
          result10th: user.profile.education.school10th.resultImage
        }
      });
    } catch (error) {
      console.error('Error uploading education documents:', error);
      res.status(500).json({ message: 'Server error while uploading education documents' });
    }
  });
  
  // Batch Management Routes
  
  // Get all batches
  app.get('/api/batches', authenticateToken, async (req, res) => {
    try {
      const batches = await Batch.find();
      res.json(batches);
    } catch (error) {
      console.error('Error fetching batches:', error);
      res.status(500).json({ message: 'Server error while fetching batches' });
    }
  });
  
  // Get batch by ID
  app.get('/api/batches/:id', authenticateToken, async (req, res) => {
    try {
      const batch = await Batch.findById(req.params.id)
        .populate('students', 'name email profile.photo');
      
      if (!batch) {
        return res.status(404).json({ message: 'Batch not found' });
      }
      
      res.json(batch);
    } catch (error) {
      console.error('Error fetching batch:', error);
      res.status(500).json({ message: 'Server error while fetching batch' });
    }
  });
  
  // Create new batch
  app.post('/api/batches', authenticateToken, async (req, res) => {
    try {
      const { name, batchId, description } = req.body;
      
      // Check if batch with this ID already exists
      const existingBatch = await Batch.findOne({ batchId });
      if (existingBatch) {
        return res.status(400).json({ message: 'Batch with this ID already exists' });
      }
      
      const newBatch = new Batch({
        name,
        batchId,
        description
      });
      
      await newBatch.save();
      
      res.status(201).json({
        message: 'Batch created successfully',
        batch: newBatch
      });
    } catch (error) {
      console.error('Error creating batch:', error);
      res.status(500).json({ message: 'Server error while creating batch' });
    }
  });
  
  // Add student to batch
  app.post('/api/batches/:id/students', authenticateToken, async (req, res) => {
    try {
      const { userId } = req.body;
      
      const batch = await Batch.findById(req.params.id);
      if (!batch) {
        return res.status(404).json({ message: 'Batch not found' });
      }
      
      const user = await User.findById(userId);
      if (!user) {
        return res.status(404).json({ message: 'User not found' });
      }
      
      // Check if user is already in batch
      if (batch.students.includes(userId)) {
        return res.status(400).json({ message: 'User already in this batch' });
      }
      
      // Add user to batch and batch to user
      batch.students.push(userId);
      user.batches.push(batch._id);
      
      await batch.save();
      await user.save();
      
      // Create notification for user
      user.notifications.push({
        message: `You have been added to batch: ${batch.name}`,
        date: new Date(),
        read: false
      });
      
      await user.save();
      
      res.json({
        message: 'Student added to batch successfully',
        batchId: batch._id,
        userId: user._id
      });
    } catch (error) {
      console.error('Error adding student to batch:', error);
      res.status(500).json({ message: 'Server error while adding student to batch' });
    }
  });
  
  // Remove student from batch
  app.delete('/api/batches/:batchId/students/:userId', authenticateToken, async (req, res) => {
    try {
      const { batchId, userId } = req.params;
      
      const batch = await Batch.findById(batchId);
      if (!batch) {
        return res.status(404).json({ message: 'Batch not found' });
      }
      
      const user = await User.findById(userId);
      if (!user) {
        return res.status(404).json({ message: 'User not found' });
      }
      
      // Remove user from batch and batch from user
      batch.students = batch.students.filter(studentId => studentId.toString() !== userId);
      user.batches = user.batches.filter(userBatchId => userBatchId.toString() !== batchId);
      
      await batch.save();
      await user.save();
      
      // Create notification for user
      user.notifications.push({
        message: `You have been removed from batch: ${batch.name}`,
        date: new Date(),
        read: false
      });
      
      await user.save();
      
      res.json({
        message: 'Student removed from batch successfully'
      });
    } catch (error) {
      console.error('Error removing student from batch:', error);
      res.status(500).json({ message: 'Server error while removing student from batch' });
    }
  });
  
  // Course Management Routes
  app.post('/api/courses', authenticateToken, upload.single('thumbnail'), async (req, res) => {
    try {
      // Check if user is admin
      // if (req.user.userType !== 'admin') {
      //   return res.status(403).json({ message: 'Unauthorized. Admin access required.' });
      // }
  
      // Upload thumbnail to Cloudinary
      let thumbnailUrl = '';
      if (req.file) {
        const result = await cloudinary.uploader.upload(req.file.path, {
          folder: 'courses'
        });
        thumbnailUrl = result.secure_url;
      }
  
      // Prepare course data
      const courseData = {
        title: req.body.title,
        courseId: req.body.courseId, // Allow custom courseId
        duration: req.body.duration,
        instructorName: req.body.instructorName,
        thumbnail: thumbnailUrl,
        language: req.body.language,
        access: req.body.access,
        startDate: req.body.startDate,
        endDate: req.body.endDate,
        about: req.body.about,
        keyFeatures: req.body.keyFeatures ? JSON.parse(req.body.keyFeatures) : [],
        isFree: req.body.isFree === 'true',
        price: req.body.price || 0,
        difficulty: req.body.difficulty || 'Beginner',
        topCourseEnabled: parseBooleanFlag(
          req.body.topCourseEnabled ?? req.body.topCourse ?? req.body.status,
          false
        ),
        createdBy: req.user.userId
      };
  
      const course = new Course(courseData);
      await course.save();
  
      res.status(201).json(course);
    } catch (error) {
      res.status(400).json({ message: error.message });
    }
  });
  
  // Get all courses (public for app listing)
  app.get('/api/courses', async (req, res) => {
    try {
      const courses = await Course.find();
      res.json(courses);
    } catch (error) {
      res.status(500).json({ message: error.message });
    }
  });
  
  // Get single course by ID (public for app details)
  app.get('/api/courses/:id', async (req, res) => {
    try {
      const course = await Course.findById(req.params.id);
      if (!course) {
        return res.status(404).json({ message: 'Course not found' });
      }
      res.json(course);
    } catch (error) {
      res.status(500).json({ message: error.message });
    }
  });
  
  // Update a course (Admin only)
  app.put('/api/courses/:id', authenticateToken, upload.single('thumbnail'), async (req, res) => {
    try {
      // Check if user is admin
      // if (req.user.userType !== 'admin') {
      //   return res.status(403).json({ message: 'Unauthorized. Admin access required.' });
      // }
  
      const courseId = req.params.id;
      const course = await Course.findById(courseId);
  
      if (!course) {
        return res.status(404).json({ message: 'Course not found' });
      }
  
      // Handle thumbnail upload
      if (req.file) {
        const result = await cloudinary.uploader.upload(req.file.path, {
          folder: 'courses'
        });
        course.thumbnail = result.secure_url;
      }
  
      // Update course fields
      course.title = req.body.title || course.title;
      course.duration = req.body.duration || course.duration;
      course.instructorName = req.body.instructorName || course.instructorName;
      course.language = req.body.language || course.language;
      course.access = req.body.access || course.access;
      course.startDate = req.body.startDate || course.startDate;
      course.endDate = req.body.endDate || course.endDate;
      course.about = req.body.about || course.about;
      course.keyFeatures = req.body.keyFeatures 
        ? JSON.parse(req.body.keyFeatures) 
        : course.keyFeatures;
      course.isFree = req.body.isFree !== undefined 
        ? req.body.isFree === 'true' 
        : course.isFree;
      course.price = req.body.price || course.price;
      course.difficulty = req.body.difficulty || course.difficulty;
      if (
        req.body.topCourseEnabled !== undefined ||
        req.body.topCourse !== undefined ||
        req.body.status !== undefined
      ) {
        course.topCourseEnabled = parseBooleanFlag(
          req.body.topCourseEnabled ?? req.body.topCourse ?? req.body.status,
          course.topCourseEnabled
        );
      }
      course.updatedAt = new Date();
  
      await course.save();
      res.json(course);
    } catch (error) {
      res.status(400).json({ message: error.message });
    }
  });
  
  // Delete a course (Admin only)
  app.delete('/api/courses/:id', authenticateToken, async (req, res) => {
    try {
      // Check if user is admin
      // if (req.user.userType !== 'admin') {
      //   return res.status(403).json({ message: 'Unauthorized. Admin access required.' });
      // }
  
      const course = await Course.findByIdAndDelete(req.params.id);
      if (!course) {
        return res.status(404).json({ message: 'Course not found' });
      }
  
      res.json({ message: 'Course deleted successfully' });
    } catch (error) {
      res.status(500).json({ message: error.message });
    }
  });

  // // Get all courses
  // app.get('/api/courses', authenticateToken, async (req, res) => {
  //   try {
  //     const courses = await Course.find();
  //     res.json(courses);
  //   } catch (error) {
  //     console.error('Error fetching courses:', error);
  //     res.status(500).json({ message: 'Server error while fetching courses' });
  //   }
  // });
  
  // // Get course by ID
  // app.get('/api/courses/:id', authenticateToken, async (req, res) => {
  //   try {
  //     const course = await Course.findById(req.params.id);
      
  //     if (!course) {
  //       return res.status(404).json({ message: 'Course not found' });
  //     }
      
  //     // Get course items for this course
  //     const courseItems = await CourseItem.find({ courseId: course._id });
      
  //     res.json({
  //       course,
  //       courseItems
  //     });
  //   } catch (error) {
  //     console.error('Error fetching course:', error);
  //     res.status(500).json({ message: 'Server error while fetching course' });
  //   }
  // });
  

  // app.post('/api/courses', authenticateToken, upload.single('image'), async (req, res) => {
  //   try {
  //     const { name, courseId, description } = req.body;
      
  //     // Check if course with this ID already exists
  //     const existingCourse = await Course.findOne({ courseId });
  //     if (existingCourse) {
  //       return res.status(400).json({ message: 'Course with this ID already exists' });
  //     }
      
  //     const newCourse = new Course({
  //       name,
  //       courseId,
  //       description,
  //       image: req.file ? req.file.path : null
  //     });
      
  //     await newCourse.save();
      
  //     res.status(201).json({
  //       message: 'Course created successfully',
  //       course: newCourse
  //     });
  //   } catch (error) {
  //     console.error('Error creating course:', error);
  //     res.status(500).json({ message: 'Server error while creating course' });
  //   }
  // });
  
  // // Add course item
  // app.post('/api/courses/:id/items', authenticateToken, upload.single('image'), async (req, res) => {
  //   try {
  //     const { name, description } = req.body;
  //     const courseId = req.params.id;
      
  //     // Check if course exists
  //     const course = await Course.findById(courseId);
  //     if (!course) {
  //       return res.status(404).json({ message: 'Course not found' });
  //     }
      
  //     const newCourseItem = new CourseItem({
  //       name,
  //       description,
  //       image: req.file ? req.file.path : null,
  //       courseId
  //     });
      
  //     await newCourseItem.save();
      
  //     res.status(201).json({
  //       message: 'Course item created successfully',
  //       courseItem: newCourseItem
  //     });
  //   } catch (error) {
  //     console.error('Error creating course item:', error);
  //     res.status(500).json({ message: 'Server error while creating course item' });
  //   }
  // });
  
  // // Add student to course
  // app.post('/api/courses/:id/students', authenticateToken, async (req, res) => {
  //   try {
  //     const { userId } = req.body;
      
  //     const course = await Course.findById(req.params.id);
  //     if (!course) {
  //       return res.status(404).json({ message: 'Course not found' });
  //     }
      
  //     const user = await User.findById(userId);
  //     if (!user) {
  //       return res.status(404).json({ message: 'User not found' });
  //     }
      
  //     // Check if user already has this course
  //     if (user.courses.includes(course._id)) {
  //       return res.status(400).json({ message: 'User already enrolled in this course' });
  //     }
      
  //     // Add course to user
  //     user.courses.push(course._id);
  //     await user.save();
      
  //     // Create notification for user
  //     user.notifications.push({
  //       message: `You have been enrolled in course: ${course.name}`,
  //       date: new Date(),
  //       read: false
  //     });
      
  //     await user.save();
      
  //     res.json({
  //       message: 'Student enrolled in course successfully',
  //       courseId: course._id,
  //       userId: user._id
  //     });
  //   } catch (error) {
  //     console.error('Error enrolling student in course:', error);
  //     res.status(500).json({ message: 'Server error while enrolling student in course' });
  //   }
  // });
  
  // Test Performance Routes
  
  // Get all tests for a user
  // app.get('/api/tests', authenticateToken, async (req, res) => {
  //   try {
  //     const userId = req.user.userId;
      
  //     const tests = await Test.find({ userId })
  //       .populate('batchId', 'name batchId')
  //       .populate('courseId', 'name courseId')
  //       .sort({ date: -1 });
      
  //     res.json(tests);
  //   } catch (error) {
  //     console.error('Error fetching tests:', error);
  //     res.status(500).json({ message: 'Server error while fetching tests' });
  //   }
  // });
  
  // // Add a new test record
  // app.post('/api/tests', authenticateToken, async (req, res) => {
  //   try {
  //     const { userId, batchId, courseId, testType, marks, totalMarks, description } = req.body;
      
  //     // Validate test type
  //     if (!['batch', 'course'].includes(testType)) {
  //       return res.status(400).json({ message: 'Invalid test type' });
  //     }
      
  //     // Check if batch exists if batchId provided
  //     if (batchId) {
  //       const batch = await Batch.findById(batchId);
  //       if (!batch) {
  //         return res.status(404).json({ message: 'Batch not found' });
  //       }
  //     }
      
  //     // Check if course exists if courseId provided
  //     if (courseId) {
  //       const course = await Course.findById(courseId);
  //       if (!course) {
  //         return res.status(404).json({ message: 'Course not found' });
  //       }
  //     }
      
  //     const newTest = new Test({
  //       userId,
  //       batchId: batchId || null,
  //       courseId: courseId || null,
  //       testType,
  //       marks,
  //       totalMarks,
  //       description
  //     });
      
  //     await newTest.save();
      
  //     // Create notification for user
  //     const user = await User.findById(userId);
  //     if (user) {
  //       user.notifications.push({
  //         message: `New test result added: ${marks}/${totalMarks} in ${testType === 'batch' ? 'batch test' : 'course test'}`,
  //         date: new Date(),
  //         read: false
  //       });
        
  //       await user.save();
  //     }
      
  //     res.status(201).json({
  //       message: 'Test record created successfully',
  //       test: newTest
  //     });
  //   } catch (error) {
  //       console.error('Error creating test record:', error);
  //       res.status(500).json({ message: 'Server error while creating test record', error: error.message });
  //   }      
  // });
  
  // Assignment Routes
  
  // Get all assignments for a user
  app.get('/api/assignments', authenticateToken, async (req, res) => {
    try {
      const userId = req.user.userId;
      
      // Get batches and courses for the user
      const user = await User.findById(userId);
      if (!user) {
        return res.status(404).json({ message: 'User not found' });
      }
      
      // Find assignments for user's batches and courses
      const assignments = await Assignment.find({
        $or: [
          { batchId: { $in: user.batches } },
          { courseId: { $in: user.courses } }
        ]
      })
      .populate('batchId', 'name batchId')
      .populate('courseId', 'name courseId')
      .sort({ deadline: 1 });
      
      // Add submission status for each assignment
      const assignmentsWithStatus = assignments.map(assignment => {
        const assignmentObj = assignment.toObject();
        
        // Check if user has submitted
        const userSubmission = assignment.submissions.find(sub => 
          sub.userId.toString() === userId
        );
        
        assignmentObj.submissionStatus = userSubmission 
          ? { submitted: true, date: userSubmission.submissionDate, marks: userSubmission.marks } 
          : { submitted: false };
        
        return assignmentObj;
      });
      
      res.json(assignmentsWithStatus);
    } catch (error) {
      console.error('Error fetching assignments:', error);
      res.status(500).json({ message: 'Server error while fetching assignments' });
    }
  });
  
  // Create a new assignment
  app.post('/api/assignments', authenticateToken, async (req, res) => {
    try {
      const { title, description, deadline, batchId, courseId } = req.body;
      
      // Validate that at least one of batchId or courseId is provided
      if (!batchId && !courseId) {
        return res.status(400).json({ message: 'Either batchId or courseId must be provided' });
      }
      
      // Check if batch exists if batchId provided
      if (batchId) {
        const batch = await Batch.findById(batchId);
        if (!batch) {
          return res.status(404).json({ message: 'Batch not found' });
        }
      }
      
      // Check if course exists if courseId provided
      if (courseId) {
        const course = await Course.findById(courseId);
        if (!course) {
          return res.status(404).json({ message: 'Course not found' });
        }
      }
      
      const newAssignment = new Assignment({
        title,
        description,
        deadline: new Date(deadline),
        batchId: batchId || null,
        courseId: courseId || null,
        submissions: []
      });
      
      await newAssignment.save();
      
      // Create notifications for all students in the batch or course
      if (batchId) {
        const batch = await Batch.findById(batchId).populate('students');
        batch.students.forEach(async (student) => {
          student.notifications.push({
            message: `New assignment in batch ${batch.name}: ${title}`,
            date: new Date(),
            read: false
          });
          await student.save();
        });
      }
      
      if (courseId) {
        const users = await User.find({ courses: courseId });
        for (const user of users) {
          user.notifications.push({
            message: `New assignment in your course: ${title}`,
            date: new Date(),
            read: false
          });
          await user.save();
        }
      }
      
      res.status(201).json({
        message: 'Assignment created successfully',
        assignment: newAssignment
      });
    } catch (error) {
      console.error('Error creating assignment:', error);
      res.status(500).json({ message: 'Server error while creating assignment' });
    }
  });
  
  // Submit assignment
  app.post('/api/assignments/:id/submit', authenticateToken, upload.single('file'), async (req, res) => {
    try {
      const assignmentId = req.params.id;
      const userId = req.user.userId;
      
      const assignment = await Assignment.findById(assignmentId);
      if (!assignment) {
        return res.status(404).json({ message: 'Assignment not found' });
      }
      
      // Check if deadline has passed
      if (new Date() > new Date(assignment.deadline)) {
        return res.status(400).json({ message: 'Assignment deadline has passed' });
      }
      
      // Check if user has already submitted
      const existingSubmission = assignment.submissions.findIndex(sub => 
        sub.userId.toString() === userId
      );
      
      if (existingSubmission !== -1) {
        // Update existing submission
        assignment.submissions[existingSubmission] = {
          userId,
          submissionDate: new Date(),
          submissionFile: req.file ? req.file.path : assignment.submissions[existingSubmission].submissionFile,
          marks: assignment.submissions[existingSubmission].marks,
          feedback: assignment.submissions[existingSubmission].feedback
        };
      } else {
        // Add new submission
        assignment.submissions.push({
          userId,
          submissionDate: new Date(),
          submissionFile: req.file ? req.file.path : null
        });
      }
      
      await assignment.save();
      
      res.json({
        message: 'Assignment submitted successfully',
        submissionDate: new Date()
      });
    } catch (error) {
      console.error('Error submitting assignment:', error);
      res.status(500).json({ message: 'Server error while submitting assignment' });
    }
  });
  
  // Payment Routes
  
  // Get payment history for a user
  app.get('/api/payments', authenticateToken, async (req, res) => {
    try {
      const userId = req.user.userId;
      
      const payments = await Payment.find({ userId })
        .sort({ date: -1 });
      
      res.json(payments);
    } catch (error) {
      console.error('Error fetching payments:', error);
      res.status(500).json({ message: 'Server error while fetching payments' });
    }
  });
  
  // Add a new payment record
  app.post('/api/payments', authenticateToken, async (req, res) => {
    try {
      const { amount, type, description, transactionId } = req.body;
      const userId = req.user.userId;
      
      // Validate payment type
      if (!['deposit', 'withdraw'].includes(type)) {
        return res.status(400).json({ message: 'Invalid payment type' });
      }
      
      const newPayment = new Payment({
        userId,
        amount,
        type,
        description,
        transactionId,
        status: 'pending'
      });
      
      await newPayment.save();
      
      // Create notification for user
      const user = await User.findById(userId);
      if (user) {
        user.notifications.push({
          message: `New ${type} of ₹${amount} recorded. Status: pending`,
          date: new Date(),
          read: false
        });
        
        await user.save();
      }
      
      res.status(201).json({
        message: 'Payment record created successfully',
        payment: newPayment
      });
    } catch (error) {
      console.error('Error creating payment record:', error);
      res.status(500).json({ message: 'Server error while creating payment record' });
    }
  });
  
  // Update payment status
  app.put('/api/payments/:id/status', authenticateToken, async (req, res) => {
    try {
      const { status } = req.body;
      const paymentId = req.params.id;
      
      // Validate status
      if (!['pending', 'completed', 'failed'].includes(status)) {
        return res.status(400).json({ message: 'Invalid payment status' });
      }
      
      const payment = await Payment.findById(paymentId);
      if (!payment) {
        return res.status(404).json({ message: 'Payment not found' });
      }
      
      payment.status = status;
      await payment.save();
      
      // Create notification for user
      const user = await User.findById(payment.userId);
      if (user) {
        user.notifications.push({
          message: `Your ${payment.type} of ₹${payment.amount} has been ${status}`,
          date: new Date(),
          read: false
        });
        
        await user.save();
      }
      
      res.json({
        message: 'Payment status updated successfully',
        payment
      });
    } catch (error) {
      console.error('Error updating payment status:', error);
      res.status(500).json({ message: 'Server error while updating payment status' });
    }
  });
  
  // Notification Routes
  
  // Get all notifications for a user
  app.get('/api/notifications', authenticateToken, async (req, res) => {
    try {
      const userId = req.user.userId;
      
      const user = await User.findById(userId);
      if (!user) {
        return res.status(404).json({ message: 'User not found' });
      }
      
      res.json({
        unreadCount: user.notifications.filter(n => !n.read).length,
        notifications: user.notifications.sort((a, b) => b.date - a.date)
      });
    } catch (error) {
      console.error('Error fetching notifications:', error);
      res.status(500).json({ message: 'Server error while fetching notifications' });
    }
  });
  
  app.put('/api/notifications/read', authenticateToken, async (req, res) => {
    try {
      const { notificationIds } = req.body;
      const userId = req.user.userId;
      
      if (!Array.isArray(notificationIds)) {
        return res.status(400).json({ message: 'notificationIds must be an array' });
      }
      
      const user = await User.findById(userId);
      if (!user) {
        return res.status(404).json({ message: 'User not found' });
      }
      
      // Mark specified notifications as read
      user.notifications.forEach(notification => {
        if (notificationIds.includes(notification._id.toString())) {
          notification.read = true;
        }
      });
      
      await user.save();
      
      res.json({
        message: 'Notifications marked as read',
        unreadCount: user.notifications.filter(n => !n.read).length
      });
    } catch (error) {
      console.error('Error marking notifications as read:', error);
      res.status(500).json({ message: 'Server error while marking notifications as read' });
    }
  });
  
  // UI Components Routes
  
  // Get UI components by type
  app.get('/api/ui-components/:type', authenticateToken, async (req, res) => {
    try {
      const { type } = req.params;
      
      // Validate type
      if (!['home', 'navbar', 'sidebar'].includes(type)) {
        return res.status(400).json({ message: 'Invalid UI component type' });
      }
      
      const components = await UIComponent.find({ type }).sort({ order: 1 });
      
      res.json(components);
    } catch (error) {
      console.error('Error fetching UI components:', error);
      res.status(500).json({ message: 'Server error while fetching UI components' });
    }
  });
  
  // Create UI component
  app.post('/api/ui-components', authenticateToken, upload.single('icon'), async (req, res) => {
    try {
      const { type, name, description, tag, order } = req.body;
      
      // Validate type
      if (!['home', 'navbar', 'sidebar'].includes(type)) {
        return res.status(400).json({ message: 'Invalid UI component type' });
      }
      
      const newComponent = new UIComponent({
        type,
        name,
        icon: req.file ? req.file.path : null,
        description,
        tag,
        order: order || 0
      });
      
      await newComponent.save();
      
      res.status(201).json({
        message: 'UI component created successfully',
        component: newComponent
      });
    } catch (error) {
      console.error('Error creating UI component:', error);
      res.status(500).json({ message: 'Server error while creating UI component' });
    }
  });
  
  // Update UI component
  app.put('/api/ui-components/:id', authenticateToken, upload.single('icon'), async (req, res) => {
    try {
      const { type, name, description, tag, order } = req.body;
      const componentId = req.params.id;
      
      const component = await UIComponent.findById(componentId);
      if (!component) {
        return res.status(404).json({ message: 'UI component not found' });
      }
      
      // Update fields if provided
      if (type) component.type = type;
      if (name) component.name = name;
      if (description) component.description = description;
      if (tag) component.tag = tag;
      if (order) component.order = order;
      if (req.file) component.icon = req.file.path;
      
      await component.save();
      
      res.json({
        message: 'UI component updated successfully',
        component
      });
    } catch (error) {
      console.error('Error updating UI component:', error);
      res.status(500).json({ message: 'Server error while updating UI component' });
    }
  });
  
  // Delete UI component
  app.delete('/api/ui-components/:id', authenticateToken, async (req, res) => {
    try {
      const componentId = req.params.id;
      
      const result = await UIComponent.deleteOne({ _id: componentId });
      
      if (result.deletedCount === 0) {
        return res.status(404).json({ message: 'UI component not found' });
      }
      
      res.json({
        message: 'UI component deleted successfully'
      });
    } catch (error) {
      console.error('Error deleting UI component:', error);
      res.status(500).json({ message: 'Server error while deleting UI component' });
    }
  });
  
  // Search Routes
  
  // Search users
  app.get('/api/search/users', authenticateToken, async (req, res) => {
    try {
      const { query } = req.query;
      
      if (!query) {
        return res.status(400).json({ message: 'Search query is required' });
      }
      
      const users = await User.find({
        $or: [
          { name: { $regex: query, $options: 'i' } },
          { email: { $regex: query, $options: 'i' } },
          { phone: { $regex: query, $options: 'i' } }
        ]
      }).select('name email phone profile.photo')
        .limit(20);
      
      res.json(users);
    } catch (error) {
      console.error('Error searching users:', error);
      res.status(500).json({ message: 'Server error while searching users' });
    }
  });
  
  // Search batches and courses
  app.get('/api/search/academic', authenticateToken, async (req, res) => {
    try {
      const { query, type } = req.query;
      
      if (!query) {
        return res.status(400).json({ message: 'Search query is required' });
      }
      
      let results = {};
      
      if (!type || type === 'batch') {
        const batches = await Batch.find({
          $or: [
            { name: { $regex: query, $options: 'i' } },
            { batchId: { $regex: query, $options: 'i' } }
          ]
        }).limit(10);
        
        results.batches = batches;
      }
      
      if (!type || type === 'course') {
        const courses = await Course.find({
          $or: [
            { name: { $regex: query, $options: 'i' } },
            { courseId: { $regex: query, $options: 'i' } }
          ]
        }).limit(10);
        
        results.courses = courses;
      }
      
      res.json(results);
    } catch (error) {
      console.error('Error searching academic items:', error);
      res.status(500).json({ message: 'Server error while searching academic items' });
    }
  });

  // GET all carousel images
app.get('/api/carouselImages', async (req, res) => {
  try {
    const images = await CarouselImage.find({}).sort({ id: 1 });
    const imageUrls = images.map(img => img.imageUrl);
    res.json(imageUrls);
  } catch (error) {
    res.status(500).json({ message: 'Error fetching carousel images', error: error.message });
  }
});

// GET all carousel images with their IDs
app.get('/api/carouselImages/withIds', async (req, res) => {
  try {
    const images = await CarouselImage.find({}).sort({ id: 1 });
    res.json(images);
  } catch (error) {
    res.status(500).json({ message: 'Error fetching carousel images', error: error.message });
  }
});

// GET a single carousel image by ID
app.get('/api/carouselImages/:id', async (req, res) => {
  try {
    const image = await CarouselImage.findOne({ id: req.params.id });
    if (!image) {
      return res.status(404).json({ message: 'Image not found' });
    }
    res.json(image);
  } catch (error) {
    res.status(500).json({ message: 'Error fetching carousel image', error: error.message });
  }
});

// // POST a new carousel image
// app.post('/api/carouselImages', async (req, res) => {
//   try {
//     const { imageUrl } = req.body;
//     if (!imageUrl) {
//       return res.status(400).json({ message: 'Image URL is required' });
//     }
    
//     // Get the highest ID and increment it
//     const highestIdImage = await CarouselImage.findOne().sort({ id: -1 });
//     const newId = highestIdImage ? String(parseInt(highestIdImage.id) + 1) : '1';
    
//     const newImage = new CarouselImage({
//       id: newId,
//       imageUrl
//     });
    
//     await newImage.save();
//     res.status(201).json(newImage);
//   } catch (error) {
//     res.status(500).json({ message: 'Error adding new carousel image', error: error.message });
//   }
// });

app.post('/api/carouselImages', upload.single('image'), async (req, res) => {
  try {
    if (!req.file || !req.file.path) {
      return res.status(400).json({ message: 'Image file is required' });
    }

    const imageUrl = req.file.path; // Cloudinary URL

    // Get the highest ID and increment it
    const highestIdImage = await CarouselImage.findOne().sort({ id: -1 });
    const newId = highestIdImage ? String(parseInt(highestIdImage.id) + 1) : '1';

    // Save image details to MongoDB
    const newImage = new CarouselImage({
      id: newId,
      imageUrl
    });

    await newImage.save();
    res.status(201).json({ message: 'Image uploaded successfully', image: newImage });
  } catch (error) {
    res.status(500).json({ message: 'Error uploading image', error: error.message });
  }
});

// PUT (update) a carousel image
app.put('/api/carouselImages/:id', upload.single('image'), async (req, res) => {
  try {
    if (!req.file || !req.file.path) {
      return res.status(400).json({ message: 'New image file is required' });
    }

    const imageUrl = req.file.path; // Cloudinary URL

    const updatedImage = await CarouselImage.findOneAndUpdate(
      { id: req.params.id },
      { imageUrl },
      { new: true }
    );

    if (!updatedImage) {
      return res.status(404).json({ message: 'Image not found' });
    }

    res.json({ message: 'Image updated successfully', image: updatedImage });
  } catch (error) {
    res.status(500).json({ message: 'Error updating carousel image', error: error.message });
  }
});

// DELETE a carousel image
app.delete('/api/carouselImages/:id', async (req, res) => {
  try {
    const deletedImage = await CarouselImage.findOneAndDelete({ id: req.params.id });
    
    if (!deletedImage) {
      return res.status(404).json({ message: 'Image not found' });
    }
    
    res.json({ message: 'Image deleted successfully' });
  } catch (error) {
    res.status(500).json({ message: 'Error deleting carousel image', error: error.message });
  }
});

app.get('/icons', async (req, res) => {
  try {
    const icons = await Icon.find({}).sort({ id: 1 });
    res.json(icons);
  } catch (error) {
    res.status(500).json({ message: 'Error fetching icons', error: error.message });
  }
});

// GET a single icon by ID
app.get('/icons/:id', async (req, res) => {
  try {
    const icon = await Icon.findOne({ id: req.params.id });
    if (!icon) {
      return res.status(404).json({ message: 'Icon not found' });
    }
    res.json(icon);
  } catch (error) {
    res.status(500).json({ message: 'Error fetching icon', error: error.message });
  }
});

// POST a new icon
app.post('/icons', async (req, res) => {
  try {
    const { image, label } = req.body;
    
    if (!label) {
      return res.status(400).json({ message: 'Label is required' });
    }
    
    // Get the highest ID and increment it
    const highestIdIcon = await Icon.findOne().sort({ id: -1 });
    const newId = highestIdIcon ? String(parseInt(highestIdIcon.id) + 1) : '1';
    
    const newIcon = new Icon({
      id: newId,
      image: image || '',
      label
    });
    
    await newIcon.save();
    res.status(201).json(newIcon);
  } catch (error) {
    res.status(500).json({ message: 'Error adding new icon', error: error.message });
  }
});

// PUT (update) an icon
app.put('/icons/:id', async (req, res) => {
  try {
    const { image, label } = req.body;
    const updateData = {};
    
    if (image !== undefined) updateData.image = image;
    if (label !== undefined) updateData.label = label;
    
    if (Object.keys(updateData).length === 0) {
      return res.status(400).json({ message: 'No update data provided' });
    }
    
    const updatedIcon = await Icon.findOneAndUpdate(
      { id: req.params.id },
      updateData,
      { new: true }
    );
    
    if (!updatedIcon) {
      return res.status(404).json({ message: 'Icon not found' });
    }
    
    res.json(updatedIcon);
  } catch (error) {
    res.status(500).json({ message: 'Error updating icon', error: error.message });
  }
});

// DELETE an icon
app.delete('/icons/:id', async (req, res) => {
  try {
    const deletedIcon = await Icon.findOneAndDelete({ id: req.params.id });
    
    if (!deletedIcon) {
      return res.status(404).json({ message: 'Icon not found' });
    }
    
    res.json({ message: 'Icon deleted successfully' });
  } catch (error) {
    res.status(500).json({ message: 'Error deleting icon', error: error.message });
  }
});

const allowedContentTypes = new Set(['ebook', 'notes']);
const allowedDifficultyLevels = new Set(['beginner', 'intermediate', 'advanced', 'general']);
const allowedPricing = new Set(['free', 'paid']);

function asText(value, fallback = '') {
  const text = (value || '').toString().trim();
  return text || fallback;
}

function normalizeContentType(value, fallback = 'ebook') {
  const normalized = asText(value, fallback).toLowerCase();
  return allowedContentTypes.has(normalized) ? normalized : fallback;
}

function normalizeDifficultyLevel(value, fallback = 'general') {
  const normalized = asText(value, fallback).toLowerCase();
  return allowedDifficultyLevels.has(normalized) ? normalized : fallback;
}

function normalizePricing(value, fallback = 'free') {
  const normalized = asText(value, fallback).toLowerCase();
  return allowedPricing.has(normalized) ? normalized : fallback;
}

function buildBookPayload(body, files, fallbackContentType = 'ebook') {
  return {
    bookName: asText(body.bookName),
    author: asText(body.author),
    description: asText(body.description),
    contentType: normalizeContentType(body.contentType, fallbackContentType),
    subject: asText(body.subject, 'General'),
    difficultyLevel: normalizeDifficultyLevel(body.difficultyLevel),
    pricing: normalizePricing(body.pricing),
    thumbnail: files && files['thumbnail'] ? files['thumbnail'][0].path : '',
    pdf: files && files['pdf'] ? files['pdf'][0].path : '',
  };
}

function buildBookUpdatePayload(body, files, fallbackContentType = 'ebook') {
  const updateData = {
    bookName: asText(body.bookName),
    author: asText(body.author),
    description: asText(body.description),
    contentType: normalizeContentType(body.contentType, fallbackContentType),
    subject: asText(body.subject, 'General'),
    difficultyLevel: normalizeDifficultyLevel(body.difficultyLevel),
    pricing: normalizePricing(body.pricing),
  };

  if (files && files['thumbnail']) {
    updateData.thumbnail = files['thumbnail'][0].path;
  }

  if (files && files['pdf']) {
    updateData.pdf = files['pdf'][0].path;
  }

  return updateData;
}

async function deleteBookById(id) {
  const book = await Book.findByIdAndDelete(id);
  if (!book) return null;

  if (book.thumbnail) {
    await cloudinary.uploader.destroy(
      book.thumbnail.split('/').pop().split('.')[0],
      { resource_type: 'image' }
    );
  }

  if (book.pdf) {
    await cloudinary.uploader.destroy(
      book.pdf.split('/').pop().split('.')[0],
      { resource_type: 'raw' }
    );
  }

  return book;
}

function resourceQueryFromRequest(req) {
  const contentType = asText(req.query.contentType).toLowerCase();
  if (allowedContentTypes.has(contentType)) {
    return { contentType };
  }
  return {};
}

app.get('/api/resources', async (req, res) => {
  try {
    const resources = await Book.find(resourceQueryFromRequest(req)).sort({ createdAt: -1 });
    res.json(resources);
  } catch (error) {
    console.error('Fetch Resources Error:', error);
    res.status(500).json({ message: 'Error fetching resources', error: error.message });
  }
});

app.get('/api/resources/:id', async (req, res) => {
  try {
    const resource = await Book.findById(req.params.id);
    if (!resource) {
      return res.status(404).json({ message: 'Resource not found' });
    }
    res.json(resource);
  } catch (error) {
    console.error('Fetch Resource Error:', error);
    res.status(500).json({ message: 'Error fetching resource', error: error.message });
  }
});

app.post('/api/resources', multiUpload, async (req, res) => {
  try {
    const payload = buildBookPayload(req.body, req.files);
    const newResource = new Book(payload);
    const savedResource = await newResource.save();
    res.status(201).json(savedResource);
  } catch (error) {
    console.error('Create Resource Error:', error);
    res.status(400).json({ message: 'Error creating resource', error: error.message });
  }
});

app.put('/api/resources/:id', multiUpload, async (req, res) => {
  try {
    const updateData = buildBookUpdatePayload(req.body, req.files);
    const updatedResource = await Book.findByIdAndUpdate(req.params.id, updateData, { new: true });

    if (!updatedResource) {
      return res.status(404).json({ message: 'Resource not found' });
    }

    res.json(updatedResource);
  } catch (error) {
    console.error('Update Resource Error:', error);
    res.status(400).json({ message: 'Error updating resource', error: error.message });
  }
});

app.delete('/api/resources/:id', async (req, res) => {
  try {
    const resource = await deleteBookById(req.params.id);
    if (!resource) {
      return res.status(404).json({ message: 'Resource not found' });
    }
    res.json({ message: 'Resource deleted successfully' });
  } catch (error) {
    console.error('Delete Resource Error:', error);
    res.status(500).json({ message: 'Error deleting resource', error: error.message });
  }
});

app.get('/api/ebooks', async (req, res) => {
  try {
    const books = await Book.find({
      $or: [{ contentType: 'ebook' }, { contentType: { $exists: false } }, { contentType: '' }],
    }).sort({ createdAt: -1 });
    res.json(books);
  } catch (error) {
    console.error('Fetch Books Error:', error);
    res.status(500).json({ message: 'Error fetching books', error: error.message });
  }
});

// GET a single book by id
app.get('/api/ebooks/:id', async (req, res) => {
  try {
    const book = await Book.findById(req.params.id);
    if (!book) {
      return res.status(404).json({ message: 'Book not found' });
    }
    res.json(book);
  } catch (error) {
    console.error('Fetch Book Error:', error);
    res.status(500).json({ message: 'Error fetching book', error: error.message });
  }
});

app.get('/api/ebooks/:id/download-url', async (req, res) => {
  try {
    const book = await Book.findById(req.params.id);
    if (!book) {
      return res.status(404).json({ message: 'Book not found' });
    }

    const pdfValue = (book.pdf || '').toString().trim();
    if (!pdfValue) {
      return res.status(404).json({ message: 'PDF not available for this book' });
    }

    // For Cloudinary image/upload PDF URLs, generate a signed download URL.
    if (
      /^https?:\/\//i.test(pdfValue) &&
      pdfValue.includes('res.cloudinary.com') &&
      pdfValue.includes('/image/upload/')
    ) {
      const match = pdfValue.match(/\/image\/upload\/(?:v\d+\/)?(.+)\.([a-zA-Z0-9]+)(?:\?|$)/);
      if (match) {
        const publicId = decodeURIComponent(match[1]);
        const format = decodeURIComponent(match[2] || 'pdf');
        const signedUrl = cloudinary.utils.private_download_url(publicId, format, {
          resource_type: 'image',
          type: 'upload',
        });
        return res.json({ url: signedUrl });
      }
    }

    return res.json({ url: pdfValue });
  } catch (error) {
    console.error('Resolve Book PDF URL Error:', error);
    return res.status(500).json({ message: 'Error resolving book PDF URL', error: error.message });
  }
});

// POST new book
app.post('/api/ebooks', multiUpload, async (req, res) => {
  try {
    const payload = buildBookPayload(req.body, req.files, 'ebook');
    payload.contentType = 'ebook';

    const newBook = new Book(payload);
    const savedBook = await newBook.save();
    res.status(201).json(savedBook);
  } catch (error) {
    console.error('Create Book Error:', error);
    res.status(400).json({ message: 'Error creating book', error: error.message });
  }
});

// PUT update book
app.put('/api/ebooks/:id', multiUpload, async (req, res) => {
  try {
    const updateData = buildBookUpdatePayload(req.body, req.files, 'ebook');
    updateData.contentType = 'ebook';

    const updatedBook = await Book.findByIdAndUpdate(req.params.id, updateData, { new: true });

    if (!updatedBook) {
      return res.status(404).json({ message: 'Book not found' });
    }

    res.json(updatedBook);
  } catch (error) {
    console.error('Update Book Error:', error);
    res.status(400).json({ message: 'Error updating book', error: error.message });
  }
});

// DELETE book
app.delete('/api/ebooks/:id', async (req, res) => {
  try {
    const book = await deleteBookById(req.params.id);

    if (!book) {
      return res.status(404).json({ message: 'Book not found' });
    }

    res.json({ message: 'Book deleted successfully' });
  } catch (error) {
    console.error('Delete Book Error:', error);
    res.status(500).json({ message: 'Error deleting book', error: error.message });
  }
});

app.get('/api/cms', async (req, res) => {
  try {
    const cms = await CMS.findOne();
    if (!cms) {
      return res.json({ terms: '', privacy: '' });
    }

    return res.json({
      terms: cms.terms || '',
      privacy: cms.privacy || '',
    });
  } catch (error) {
    return res.status(500).json({ message: 'Error fetching CMS data', error: error.message });
  }
});

app.put('/api/cms', authenticateToken, async (req, res) => {
  try {
    const { type, description } = req.body;
    const safeType = String(type || '').trim().toLowerCase();

    if (!['terms', 'privacy'].includes(safeType)) {
      return res.status(400).json({ message: 'type must be terms or privacy' });
    }

    if (typeof description !== 'string' || description.trim() === '') {
      return res.status(400).json({ message: 'Description is required' });
    }

    let cms = await CMS.findOne();
    if (!cms) {
      cms = new CMS();
    }

    cms[safeType] = description.trim();
    await cms.save();

    return res.json({
      message: `${safeType} saved`,
      terms: cms.terms || '',
      privacy: cms.privacy || '',
    });
  } catch (error) {
    return res.status(500).json({ message: 'Error saving CMS data', error: error.message });
  }
});

app.get('/api/faqs', async (req, res) => {
  try {
    const faqs = await FAQ.find().sort({ createdAt: -1 });
    return res.json(faqs);
  } catch (error) {
    return res.status(500).json({ message: 'Error fetching FAQs', error: error.message });
  }
});

app.post('/api/faqs', authenticateToken, async (req, res) => {
  try {
    const question = String(req.body.question || '').trim();
    const answer = String(req.body.answer || '').trim();

    if (!question || !answer) {
      return res.status(400).json({ message: 'Question and answer are required' });
    }

    const faq = await FAQ.create({ question, answer });
    return res.status(201).json(faq);
  } catch (error) {
    return res.status(500).json({ message: 'Error creating FAQ', error: error.message });
  }
});

app.put('/api/faqs/:id', authenticateToken, async (req, res) => {
  try {
    const question = String(req.body.question || '').trim();
    const answer = String(req.body.answer || '').trim();

    if (!question || !answer) {
      return res.status(400).json({ message: 'Question and answer are required' });
    }

    const faq = await FAQ.findByIdAndUpdate(
      req.params.id,
      { question, answer },
      { new: true, runValidators: true }
    );

    if (!faq) {
      return res.status(404).json({ message: 'FAQ not found' });
    }

    return res.json(faq);
  } catch (error) {
    return res.status(500).json({ message: 'Error updating FAQ', error: error.message });
  }
});

app.delete('/api/faqs/:id', authenticateToken, async (req, res) => {
  try {
    const faq = await FAQ.findByIdAndDelete(req.params.id);
    if (!faq) {
      return res.status(404).json({ message: 'FAQ not found' });
    }
    return res.json({ message: 'FAQ deleted successfully' });
  } catch (error) {
    return res.status(500).json({ message: 'Error deleting FAQ', error: error.message });
  }
});

app.get('/api/current-affairs', async (req, res) => {
  try {
    const currentAffairs = await CurrentAffair.find({ isActive: true }).sort({ publishedAt: -1, createdAt: -1 });
    return res.json(currentAffairs);
  } catch (error) {
    return res.status(500).json({ message: 'Error fetching current affairs', error: error.message });
  }
});

app.post('/api/current-affairs', authenticateToken, upload.single('img'), async (req, res) => {
  try {
    const question = String(req.body.question || '').trim();
    const answer = String(req.body.answer || '').trim();
    const img = String(req.file?.path || req.body.img || '').trim();
    const source = String(req.body.source || '').trim();
    const publishedAt = req.body.publishedAt ? new Date(req.body.publishedAt) : new Date();

    if (!question || !answer) {
      return res.status(400).json({ message: 'Question and answer are required' });
    }

    if (Number.isNaN(publishedAt.getTime())) {
      return res.status(400).json({ message: 'Invalid published date' });
    }

    const currentAffair = await CurrentAffair.create({
      question,
      answer,
      img,
      source,
      publishedAt,
      isActive: true,
    });
    return res.status(201).json(currentAffair);
  } catch (error) {
    return res.status(500).json({ message: 'Error creating current affair', error: error.message });
  }
});

app.put('/api/current-affairs/:id', authenticateToken, upload.single('img'), async (req, res) => {
  try {
    const hasQuestion = typeof req.body.question !== 'undefined';
    const hasAnswer = typeof req.body.answer !== 'undefined';
    const hasSource = typeof req.body.source !== 'undefined';
    const question = hasQuestion ? String(req.body.question || '').trim() : undefined;
    const answer = hasAnswer ? String(req.body.answer || '').trim() : undefined;
    const img = String(req.file?.path || req.body.img || '').trim();
    const source = hasSource ? String(req.body.source || '').trim() : undefined;
    const publishedAt = req.body.publishedAt ? new Date(req.body.publishedAt) : undefined;

    if (hasQuestion && !question) {
      return res.status(400).json({ message: 'Question is required' });
    }

    if (hasAnswer && !answer) {
      return res.status(400).json({ message: 'Answer is required' });
    }

    if (publishedAt && Number.isNaN(publishedAt.getTime())) {
      return res.status(400).json({ message: 'Invalid published date' });
    }

    const payload = { isActive: true };

    if (hasQuestion) {
      payload.question = question;
    }
    if (hasAnswer) {
      payload.answer = answer;
    }
    if (hasSource) {
      payload.source = source;
    }

    if (publishedAt) {
      payload.publishedAt = publishedAt;
    }
    if (img) {
      payload.img = img;
    }

    const currentAffair = await CurrentAffair.findByIdAndUpdate(req.params.id, payload, {
      new: true,
      runValidators: true,
    });

    if (!currentAffair) {
      return res.status(404).json({ message: 'Current affair not found' });
    }

    return res.json(currentAffair);
  } catch (error) {
    return res.status(500).json({ message: 'Error updating current affair', error: error.message });
  }
});

app.delete('/api/current-affairs/:id', authenticateToken, async (req, res) => {
  try {
    const currentAffair = await CurrentAffair.findByIdAndDelete(req.params.id);
    if (!currentAffair) {
      return res.status(404).json({ message: 'Current affair not found' });
    }
    return res.json({ message: 'Current affair deleted successfully' });
  } catch (error) {
    return res.status(500).json({ message: 'Error deleting current affair', error: error.message });
  }
});

function normalizeJobSector(value) {
  const sector = String(value || '').trim().toLowerCase();
  if (sector === 'govt' || sector === 'government') return 'govt';
  if (sector === 'pvt' || sector === 'private') return 'pvt';
  return '';
}

app.get('/api/jobs', async (req, res) => {
  try {
    const requestedSector = normalizeJobSector(req.query.sector);
    const filters = { isActive: true };
    if (requestedSector) {
      filters.sector = requestedSector;
    }

    const jobs = await JobListing.find(filters).sort({ createdAt: -1 });
    return res.json(jobs);
  } catch (error) {
    return res.status(500).json({ message: 'Error fetching jobs', error: error.message });
  }
});

app.get('/api/jobs/:id', async (req, res) => {
  try {
    const job = await JobListing.findById(req.params.id);
    if (!job || !job.isActive) {
      return res.status(404).json({ message: 'Job not found' });
    }
    return res.json(job);
  } catch (error) {
    return res.status(500).json({ message: 'Error fetching job', error: error.message });
  }
});

app.post('/api/jobs', authenticateToken, async (req, res) => {
  try {
    const title = String(req.body.title || '').trim();
    const organisationName = String(req.body.organisationName || '').trim();
    const postName = String(req.body.postName || '').trim();
    const noOfVacancies = Number(req.body.noOfVacancies);
    const qualificationNeeded = String(req.body.qualificationNeeded || '').trim();
    const lastDateToApply = new Date(req.body.lastDateToApply);
    const linkToApply = String(req.body.linkToApply || '').trim();
    const sector = normalizeJobSector(req.body.sector);

    if (!title || !organisationName || !postName || !qualificationNeeded || !linkToApply) {
      return res.status(400).json({ message: 'All job fields are required' });
    }

    if (!Number.isInteger(noOfVacancies) || noOfVacancies <= 0) {
      return res.status(400).json({ message: 'No. of vacancies must be a positive whole number' });
    }

    if (Number.isNaN(lastDateToApply.getTime())) {
      return res.status(400).json({ message: 'Invalid last date to apply' });
    }

    if (!sector) {
      return res.status(400).json({ message: 'Sector must be govt or pvt' });
    }

    const job = await JobListing.create({
      title,
      organisationName,
      postName,
      noOfVacancies,
      qualificationNeeded,
      lastDateToApply,
      linkToApply,
      sector,
      isActive: true,
    });

    return res.status(201).json(job);
  } catch (error) {
    return res.status(500).json({ message: 'Error creating job', error: error.message });
  }
});

app.put('/api/jobs/:id', authenticateToken, async (req, res) => {
  try {
    const payload = {};

    if (typeof req.body.title !== 'undefined') {
      const title = String(req.body.title || '').trim();
      if (!title) return res.status(400).json({ message: 'Title is required' });
      payload.title = title;
    }

    if (typeof req.body.organisationName !== 'undefined') {
      const organisationName = String(req.body.organisationName || '').trim();
      if (!organisationName) return res.status(400).json({ message: 'Organisation name is required' });
      payload.organisationName = organisationName;
    }

    if (typeof req.body.postName !== 'undefined') {
      const postName = String(req.body.postName || '').trim();
      if (!postName) return res.status(400).json({ message: 'Post name is required' });
      payload.postName = postName;
    }

    if (typeof req.body.noOfVacancies !== 'undefined') {
      const noOfVacancies = Number(req.body.noOfVacancies);
      if (!Number.isInteger(noOfVacancies) || noOfVacancies <= 0) {
        return res.status(400).json({ message: 'No. of vacancies must be a positive whole number' });
      }
      payload.noOfVacancies = noOfVacancies;
    }

    if (typeof req.body.qualificationNeeded !== 'undefined') {
      const qualificationNeeded = String(req.body.qualificationNeeded || '').trim();
      if (!qualificationNeeded) return res.status(400).json({ message: 'Qualification is required' });
      payload.qualificationNeeded = qualificationNeeded;
    }

    if (typeof req.body.lastDateToApply !== 'undefined') {
      const lastDateToApply = new Date(req.body.lastDateToApply);
      if (Number.isNaN(lastDateToApply.getTime())) {
        return res.status(400).json({ message: 'Invalid last date to apply' });
      }
      payload.lastDateToApply = lastDateToApply;
    }

    if (typeof req.body.linkToApply !== 'undefined') {
      const linkToApply = String(req.body.linkToApply || '').trim();
      if (!linkToApply) return res.status(400).json({ message: 'Apply link is required' });
      payload.linkToApply = linkToApply;
    }

    if (typeof req.body.sector !== 'undefined') {
      const sector = normalizeJobSector(req.body.sector);
      if (!sector) return res.status(400).json({ message: 'Sector must be govt or pvt' });
      payload.sector = sector;
    }

    payload.isActive = true;

    const job = await JobListing.findByIdAndUpdate(req.params.id, payload, {
      new: true,
      runValidators: true,
    });

    if (!job) {
      return res.status(404).json({ message: 'Job not found' });
    }

    return res.json(job);
  } catch (error) {
    return res.status(500).json({ message: 'Error updating job', error: error.message });
  }
});

app.delete('/api/jobs/:id', authenticateToken, async (req, res) => {
  try {
    const job = await JobListing.findByIdAndDelete(req.params.id);
    if (!job) {
      return res.status(404).json({ message: 'Job not found' });
    }
    return res.json({ message: 'Job deleted successfully' });
  } catch (error) {
    return res.status(500).json({ message: 'Error deleting job', error: error.message });
  }
});

app.get('/api/testimonials', async (req, res) => {
  try {
    const testimonials = await Testimonial.find({ isActive: true }).sort({ createdAt: -1 });
    return res.json(testimonials);
  } catch (error) {
    return res.status(500).json({ message: 'Error fetching testimonials', error: error.message });
  }
});

app.post('/api/testimonials', authenticateToken, async (req, res) => {
  try {
    const name = String(req.body.name || '').trim();
    const designation = String(req.body.designation || '').trim();
    const message = String(req.body.message || '').trim();
    const rating = Number(req.body.rating || 5);

    if (!name || !message) {
      return res.status(400).json({ message: 'Name and message are required' });
    }

    if (!Number.isInteger(rating) || rating < 1 || rating > 5) {
      return res.status(400).json({ message: 'Rating must be an integer between 1 and 5' });
    }

    const testimonial = await Testimonial.create({
      name,
      designation,
      message,
      rating,
      isActive: true,
    });

    return res.status(201).json(testimonial);
  } catch (error) {
    return res.status(500).json({ message: 'Error creating testimonial', error: error.message });
  }
});

app.put('/api/testimonials/:id', authenticateToken, async (req, res) => {
  try {
    const name = String(req.body.name || '').trim();
    const designation = String(req.body.designation || '').trim();
    const message = String(req.body.message || '').trim();
    const rating = Number(req.body.rating || 5);

    if (!name || !message) {
      return res.status(400).json({ message: 'Name and message are required' });
    }

    if (!Number.isInteger(rating) || rating < 1 || rating > 5) {
      return res.status(400).json({ message: 'Rating must be an integer between 1 and 5' });
    }

    const testimonial = await Testimonial.findByIdAndUpdate(
      req.params.id,
      { name, designation, message, rating, isActive: true },
      { new: true, runValidators: true }
    );

    if (!testimonial) {
      return res.status(404).json({ message: 'Testimonial not found' });
    }

    return res.json(testimonial);
  } catch (error) {
    return res.status(500).json({ message: 'Error updating testimonial', error: error.message });
  }
});

app.delete('/api/testimonials/:id', authenticateToken, async (req, res) => {
  try {
    const testimonial = await Testimonial.findByIdAndDelete(req.params.id);
    if (!testimonial) {
      return res.status(404).json({ message: 'Testimonial not found' });
    }
    return res.json({ message: 'Testimonial deleted successfully' });
  } catch (error) {
    return res.status(500).json({ message: 'Error deleting testimonial', error: error.message });
  }
});

app.get('/api/online-classes', async (req, res) => {
  try {
    const onlineClasses = await OnlineClass.find({ isActive: true }).sort({ createdAt: -1 });
    return res.json(onlineClasses);
  } catch (error) {
    return res.status(500).json({ message: 'Error fetching online classes', error: error.message });
  }
});

app.post('/api/online-classes', authenticateToken, upload.single('img'), async (req, res) => {
  try {
    const title = String(req.body.title || '').trim();
    const date = String(req.body.date || '').trim();
    const time = String(req.body.time || '').trim();
    const description = String(req.body.description || '').trim();

    if (!title || !date || !time || !description) {
      return res.status(400).json({ message: 'Title, date, time, and description are required' });
    }

    const onlineClass = await OnlineClass.create({
      img: req.file?.path || '',
      title,
      date,
      time,
      description,
      isActive: true,
    });

    return res.status(201).json(onlineClass);
  } catch (error) {
    return res.status(500).json({ message: 'Error creating online class', error: error.message });
  }
});

app.put('/api/online-classes/:id', authenticateToken, upload.single('img'), async (req, res) => {
  try {
    const title = String(req.body.title || '').trim();
    const date = String(req.body.date || '').trim();
    const time = String(req.body.time || '').trim();
    const description = String(req.body.description || '').trim();

    if (!title || !date || !time || !description) {
      return res.status(400).json({ message: 'Title, date, time, and description are required' });
    }

    const updateData = { title, date, time, description, isActive: true };
    if (req.file?.path) {
      updateData.img = req.file.path;
    }

    const onlineClass = await OnlineClass.findByIdAndUpdate(req.params.id, updateData, {
      new: true,
      runValidators: true,
    });

    if (!onlineClass) {
      return res.status(404).json({ message: 'Online class not found' });
    }

    return res.json(onlineClass);
  } catch (error) {
    return res.status(500).json({ message: 'Error updating online class', error: error.message });
  }
});

app.delete('/api/online-classes/:id', authenticateToken, async (req, res) => {
  try {
    const onlineClass = await OnlineClass.findByIdAndDelete(req.params.id);
    if (!onlineClass) {
      return res.status(404).json({ message: 'Online class not found' });
    }

    return res.json({ message: 'Online class deleted successfully' });
  } catch (error) {
    return res.status(500).json({ message: 'Error deleting online class', error: error.message });
  }
});

app.get('/api/youtube-links', async (req, res) => {
  try {
    const youtubeLinks = await YoutubeLink.find({ isActive: true }).sort({ createdAt: -1 });
    return res.json(youtubeLinks);
  } catch (error) {
    return res.status(500).json({ message: 'Error fetching youtube links', error: error.message });
  }
});

app.post('/api/youtube-links', authenticateToken, async (req, res) => {
  try {
    const title = String(req.body.title || '').trim();
    const link = String(req.body.link || '').trim();
    const description = String(req.body.description || '').trim();

    if (!title || !link || !description) {
      return res.status(400).json({ message: 'Title, link, and description are required' });
    }

    const youtubeLink = await YoutubeLink.create({
      title,
      link,
      description,
      isActive: true,
    });

    return res.status(201).json(youtubeLink);
  } catch (error) {
    return res.status(500).json({ message: 'Error creating youtube link', error: error.message });
  }
});

app.put('/api/youtube-links/:id', authenticateToken, async (req, res) => {
  try {
    const title = String(req.body.title || '').trim();
    const link = String(req.body.link || '').trim();
    const description = String(req.body.description || '').trim();

    if (!title || !link || !description) {
      return res.status(400).json({ message: 'Title, link, and description are required' });
    }

    const youtubeLink = await YoutubeLink.findByIdAndUpdate(
      req.params.id,
      { title, link, description, isActive: true },
      { new: true, runValidators: true }
    );

    if (!youtubeLink) {
      return res.status(404).json({ message: 'Youtube link not found' });
    }

    return res.json(youtubeLink);
  } catch (error) {
    return res.status(500).json({ message: 'Error updating youtube link', error: error.message });
  }
});

app.delete('/api/youtube-links/:id', authenticateToken, async (req, res) => {
  try {
    const youtubeLink = await YoutubeLink.findByIdAndDelete(req.params.id);
    if (!youtubeLink) {
      return res.status(404).json({ message: 'Youtube link not found' });
    }

    return res.json({ message: 'Youtube link deleted successfully' });
  } catch (error) {
    return res.status(500).json({ message: 'Error deleting youtube link', error: error.message });
  }
});

app.post('/api/resumes', authenticateToken, async (req, res) => {
  try {
    const userId = req.user?.userId;
    if (!userId) {
      return res.status(401).json({ message: 'Unauthorized user' });
    }

    const payload = req.body || {};

    const education = Array.isArray(payload.education)
      ? payload.education.map((item) => ({
          degree: String(item?.degree || '').trim(),
          college: String(item?.college || '').trim(),
          location: String(item?.location || '').trim(),
          gpa: String(item?.gpa || '').trim(),
          coursework: String(item?.coursework || '').trim(),
          title: String(item?.title || '').trim(),
        }))
      : [];

    const experience = Array.isArray(payload.experience)
      ? payload.experience.map((item) => ({
          company: String(item?.company || '').trim(),
          position: String(item?.position || '').trim(),
          startDate: String(item?.startDate || '').trim(),
          endDate: String(item?.endDate || '').trim(),
          location: String(item?.location || '').trim(),
          description: String(item?.description || '').trim(),
        }))
      : [];

    const skills = Array.isArray(payload.skills)
      ? payload.skills.map((item) => String(item || '').trim()).filter(Boolean)
      : [];

    const hobbies = Array.isArray(payload.hobbies)
      ? payload.hobbies.map((item) => String(item || '').trim()).filter(Boolean)
      : [];

    const resumeData = {
      userId,
      name: String(payload.name || '').trim(),
      phone: String(payload.phone || '').trim(),
      address: String(payload.address || '').trim(),
      email: String(payload.email || '').trim().toLowerCase(),
      summary: String(payload.summary || '').trim(),
      education,
      experience,
      skills,
      hobbies,
    };

    if (!resumeData.name || !resumeData.phone || !resumeData.address || !resumeData.email || !resumeData.summary) {
      return res.status(400).json({ message: 'Name, phone, address, email, and summary are required' });
    }

    if (!education.length || education.some((item) => !item.degree || !item.college || !item.location)) {
      return res.status(400).json({ message: 'Each education entry needs degree, college, and location' });
    }

    if (!experience.length || experience.some((item) => !item.company || !item.position || !item.startDate)) {
      return res.status(400).json({ message: 'Each experience entry needs company, position, and start date' });
    }

    const resume = await Resume.create(resumeData);
    return res.status(201).json(resume);
  } catch (error) {
    return res.status(500).json({ message: 'Error saving resume', error: error.message });
  }
});

app.get('/api/resumes', authenticateToken, async (req, res) => {
  try {
    const userId = req.user?.userId;
    if (!userId) {
      return res.status(401).json({ message: 'Unauthorized user' });
    }

    const resumes = await Resume.find({ userId }).sort({ createdAt: -1 });
    return res.json(resumes);
  } catch (error) {
    return res.status(500).json({ message: 'Error fetching resumes', error: error.message });
  }
});

app.get('/api/resumes/:id', authenticateToken, async (req, res) => {
  try {
    const userId = req.user?.userId;
    if (!userId) {
      return res.status(401).json({ message: 'Unauthorized user' });
    }

    const resume = await Resume.findOne({ _id: req.params.id, userId });
    if (!resume) {
      return res.status(404).json({ message: 'Resume not found' });
    }

    return res.json(resume);
  } catch (error) {
    return res.status(500).json({ message: 'Error fetching resume', error: error.message });
  }
});

app.put('/api/resumes/:id', authenticateToken, async (req, res) => {
  try {
    const userId = req.user?.userId;
    if (!userId) {
      return res.status(401).json({ message: 'Unauthorized user' });
    }

    const payload = req.body || {};
    const updateData = {};

    if (payload.name !== undefined) updateData.name = String(payload.name || '').trim();
    if (payload.phone !== undefined) updateData.phone = String(payload.phone || '').trim();
    if (payload.address !== undefined) updateData.address = String(payload.address || '').trim();
    if (payload.email !== undefined) updateData.email = String(payload.email || '').trim().toLowerCase();
    if (payload.summary !== undefined) updateData.summary = String(payload.summary || '').trim();

    if (Array.isArray(payload.education)) {
      updateData.education = payload.education.map((item) => ({
        degree: String(item?.degree || '').trim(),
        college: String(item?.college || '').trim(),
        location: String(item?.location || '').trim(),
        gpa: String(item?.gpa || '').trim(),
        coursework: String(item?.coursework || '').trim(),
        title: String(item?.title || '').trim(),
      }));
    }

    if (Array.isArray(payload.experience)) {
      updateData.experience = payload.experience.map((item) => ({
        company: String(item?.company || '').trim(),
        position: String(item?.position || '').trim(),
        startDate: String(item?.startDate || '').trim(),
        endDate: String(item?.endDate || '').trim(),
        location: String(item?.location || '').trim(),
        description: String(item?.description || '').trim(),
      }));
    }

    if (Array.isArray(payload.skills)) {
      updateData.skills = payload.skills.map((item) => String(item || '').trim()).filter(Boolean);
    }

    if (Array.isArray(payload.hobbies)) {
      updateData.hobbies = payload.hobbies.map((item) => String(item || '').trim()).filter(Boolean);
    }

    const resume = await Resume.findOneAndUpdate(
      { _id: req.params.id, userId },
      updateData,
      { new: true, runValidators: true }
    );

    if (!resume) {
      return res.status(404).json({ message: 'Resume not found' });
    }

    return res.json(resume);
  } catch (error) {
    return res.status(500).json({ message: 'Error updating resume', error: error.message });
  }
});

app.delete('/api/resumes/:id', authenticateToken, async (req, res) => {
  try {
    const userId = req.user?.userId;
    if (!userId) {
      return res.status(401).json({ message: 'Unauthorized user' });
    }

    const resume = await Resume.findOneAndDelete({ _id: req.params.id, userId });
    if (!resume) {
      return res.status(404).json({ message: 'Resume not found' });
    }

    return res.json({ message: 'Resume deleted successfully' });
  } catch (error) {
    return res.status(500).json({ message: 'Error deleting resume', error: error.message });
  }
});

// Legacy endpoint used by existing app FAQ page.
app.get(['/api/questions', '/questions'], async (req, res) => {
  try {
    const [faqs, currentAffairs, testimonials] = await Promise.all([
      FAQ.find().sort({ createdAt: -1 }),
      CurrentAffair.find({ isActive: true }).sort({ publishedAt: -1, createdAt: -1 }),
      Testimonial.find({ isActive: true }).sort({ createdAt: -1 }),
    ]);

    const faqQuestions = faqs.map((faq) => ({
      _id: faq._id,
      type: 'faq',
      question: faq.question,
      answer: faq.answer,
      createdAt: faq.createdAt,
      updatedAt: faq.updatedAt,
    }));

    const currentAffairQuestions = currentAffairs.map((item) => ({
      _id: item._id,
      type: 'currentAffairs',
      question: item.question,
      answer: item.answer,
      source: item.source,
      publishedAt: item.publishedAt,
      createdAt: item.createdAt,
      updatedAt: item.updatedAt,
    }));

    const testimonialQuestions = testimonials.map((item) => ({
      _id: item._id,
      type: 'Testimonial',
      question: item.name,
      answer: item.message,
      designation: item.designation,
      rating: item.rating,
      createdAt: item.createdAt,
      updatedAt: item.updatedAt,
    }));

    const questions = [...currentAffairQuestions, ...faqQuestions, ...testimonialQuestions].sort((a, b) => {
      const dateA = new Date(a.publishedAt || a.createdAt || 0).getTime();
      const dateB = new Date(b.publishedAt || b.createdAt || 0).getTime();
      return dateB - dateA;
    });

    return res.json(questions);
  } catch (error) {
    return res.status(500).json({ message: 'Error fetching questions', error: error.message });
  }
});



// ✅ Create a new test (POST)
app.post('/api/tests', validateTest, async (req, res) => {
  try {
    const newTest = new Test(req.body);
    await newTest.save();
    res.status(201).json(newTest);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
});

// ✅ Get all tests (Only basic info)
app.get('/api/tests', async (req, res) => {
  try {
    const tests = await Test.find().select('title topic description duration questionCount');
    res.json(tests);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// ✅ Get a specific test (Detailed info)
app.get('/api/tests/:id', async (req, res) => {
  try {
    const test = await Test.findById(req.params.id);
    if (!test) return res.status(404).json({ message: 'Test not found' });

    const formattedTest = {
      title: test.title,
      topic: test.topic,
      description: test.description,
      duration: test.duration,
      questionCount: test.questions.length,
      questions: test.questions.map((q, index) => ({
        number: index + 1,
        questionText: q.questionText,
        options: {
          option1: q.options.option1,
          option2: q.options.option2,
          option3: q.options.option3,
          option4: q.options.option4
        },
        correctOption: q.correctOption,
        solution: q.solution
      }))
    };

    res.json(formattedTest);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// ✅ Update a test (PUT)
app.put('/api/tests/:id', validateTest, async (req, res) => {
  try {
    const updatedTest = await Test.findByIdAndUpdate(
      req.params.id, 
      req.body, 
      { new: true, runValidators: true }
    );

    if (!updatedTest) return res.status(404).json({ message: 'Test not found' });

    res.json(updatedTest);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
});

// ✅ Delete a test (DELETE)
app.delete('/api/tests/:id', async (req, res) => {
  try {
    const deletedTest = await Test.findByIdAndDelete(req.params.id);

    if (!deletedTest) return res.status(404).json({ message: 'Test not found' });

    res.json({ message: 'Test deleted successfully' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Routes

// Create a new test
app.post('/api/tests', validateTest, async (req, res) => {
  try {
    const newTest = new Test(req.body);
    await newTest.save();
    res.status(201).json(newTest);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
});

// Get all tests
app.get('/api/tests', async (req, res) => {
  try {
    const tests = await Test.find().select('-questions');
    res.json(tests);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Get a specific test by ID
app.get('/api/tests/:id', async (req, res) => {
  try {
    const test = await Test.findById(req.params.id);
    if (!test) {
      return res.status(404).json({ message: 'Test not found' });
    }
    res.json(test);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Update a test
app.put('/api/tests/:id', validateTest, async (req, res) => {
  try {
    const updatedTest = await Test.findByIdAndUpdate(
      req.params.id, 
      req.body, 
      { new: true, runValidators: true }
    );

    if (!updatedTest) {
      return res.status(404).json({ message: 'Test not found' });
    }

    res.json(updatedTest);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
});

// Delete a test
app.delete('/api/tests/:id', async (req, res) => {
  try {
    const deletedTest = await Test.findByIdAndDelete(req.params.id);

    if (!deletedTest) {
      return res.status(404).json({ message: 'Test not found' });
    }

    res.json({ message: 'Test deleted successfully' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Additional route for getting test details with full questions
app.get('/api/tests/:id/details', async (req, res) => {
  try {
    const test = await Test.findById(req.params.id);
    if (!test) {
      return res.status(404).json({ message: 'Test not found' });
    }
    res.json({
      title: test.title,
      duration: test.duration,
      questionCount: test.questions.length
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Global fallback for unhandled route errors
app.use((err, req, res, next) => {
  const route = req.originalUrl || req.url || 'unknown-route';
  const method = req.method || 'UNKNOWN';
  console.error(`[UNHANDLED_ROUTE_ERROR] ${method} ${route}`, err);

  if (res.headersSent) {
    return next(err);
  }

  return res.status(500).json({ message: 'Internal server error' });
});

  
  // Vercel Serverless Configuration
  if (process.env.VERCEL) {
    // Export the Express app as a Vercel serverless function
    module.exports = app;
  } else {
    // Start the server for local development
    app.listen(PORT, () => {
      console.log(`Server running on port ${PORT}`);
    });
  }

