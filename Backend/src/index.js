const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const compression = require('compression');
const { createServer } = require('http');
const { Server } = require('socket.io');
require('dotenv').config();

const authRoutes = require('./routes/auth');
const leagueRoutes = require('./routes/leagues');
const playerRoutes = require('./routes/players');
const draftRoutes = require('./routes/draft');
const teamRoutes = require('./routes/teams');
const matchupRoutes = require('./routes/matchups');
const tradeRoutes = require('./routes/trades');
const waiverRoutes = require('./routes/waivers');

const { errorHandler } = require('./middleware/errorHandler');
const { rateLimiter } = require('./middleware/rateLimiter');
const { authenticateToken } = require('./middleware/auth');
const { logger } = require('./utils/logger');

const app = express();
const server = createServer(app);
const io = new Server(server, {
  cors: {
    origin: process.env.FRONTEND_URL || "http://localhost:3000",
    methods: ["GET", "POST"]
  }
});

// Middleware
app.use(helmet());
app.use(cors({
  origin: process.env.FRONTEND_URL || "http://localhost:3000",
  credentials: true
}));
app.use(compression());
app.use(morgan('combined', { stream: { write: message => logger.info(message.trim()) } }));
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));
app.use(rateLimiter);

// Health check endpoint
app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'OK',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    environment: process.env.NODE_ENV || 'development'
  });
});

// API Routes
app.use('/api/auth', authRoutes);
app.use('/api/leagues', authenticateToken, leagueRoutes);
app.use('/api/players', authenticateToken, playerRoutes);
app.use('/api/draft', authenticateToken, draftRoutes);
app.use('/api/teams', authenticateToken, teamRoutes);
app.use('/api/matchups', authenticateToken, matchupRoutes);
app.use('/api/trades', authenticateToken, tradeRoutes);
app.use('/api/waivers', authenticateToken, waiverRoutes);

// Socket.IO connection handling
io.on('connection', (socket) => {
  logger.info(`User connected: ${socket.id}`);
  
  // Join draft room
  socket.on('join-draft', (leagueId) => {
    socket.join(`draft-${leagueId}`);
    logger.info(`User ${socket.id} joined draft room for league ${leagueId}`);
  });
  
  // Leave draft room
  socket.on('leave-draft', (leagueId) => {
    socket.leave(`draft-${leagueId}`);
    logger.info(`User ${socket.id} left draft room for league ${leagueId}`);
  });
  
  // Draft pick made
  socket.on('draft-pick', (data) => {
    socket.to(`draft-${data.leagueId}`).emit('pick-made', data);
    logger.info(`Draft pick made in league ${data.leagueId}: ${data.playerName}`);
  });
  
  // Join league room for real-time updates
  socket.on('join-league', (leagueId) => {
    socket.join(`league-${leagueId}`);
    logger.info(`User ${socket.id} joined league room ${leagueId}`);
  });
  
  // Leave league room
  socket.on('leave-league', (leagueId) => {
    socket.leave(`league-${leagueId}`);
    logger.info(`User ${socket.id} left league room ${leagueId}`);
  });
  
  // Trade offer
  socket.on('trade-offer', (data) => {
    socket.to(`league-${data.leagueId}`).emit('new-trade', data);
    logger.info(`Trade offer made in league ${data.leagueId}`);
  });
  
  // Waiver claim
  socket.on('waiver-claim', (data) => {
    socket.to(`league-${data.leagueId}`).emit('waiver-update', data);
    logger.info(`Waiver claim made in league ${data.leagueId}`);
  });
  
  socket.on('disconnect', () => {
    logger.info(`User disconnected: ${socket.id}`);
  });
});

// Error handling middleware
app.use(errorHandler);

// 404 handler
app.use('*', (req, res) => {
  res.status(404).json({
    error: 'Route not found',
    path: req.originalUrl,
    method: req.method
  });
});

// Make io available to routes
app.set('io', io);

const PORT = process.env.PORT || 3001;

server.listen(PORT, () => {
  logger.info(`Fantasy Soccer API server running on port ${PORT}`);
  logger.info(`Environment: ${process.env.NODE_ENV || 'development'}`);
});

// Graceful shutdown
process.on('SIGTERM', () => {
  logger.info('SIGTERM received, shutting down gracefully');
  server.close(() => {
    logger.info('Process terminated');
    process.exit(0);
  });
});

process.on('SIGINT', () => {
  logger.info('SIGINT received, shutting down gracefully');
  server.close(() => {
    logger.info('Process terminated');
    process.exit(0);
  });
});

module.exports = { app, server, io }; 