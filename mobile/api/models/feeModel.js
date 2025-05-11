import connection from '../config/mysqlconnectivity.js';

export const createFee = (feeData, callback) => {
  const query = `
    INSERT INTO fee_collections (
      student_id, student_name, class_name, fee_month, payment_date,
      monthly_fee, admission_fee, registration_fee, art_material,
      transport, books, uniform, fine, others,
      previous_balance, total_amount, due_balance, deposit
    ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
  `;
    
  const values = [
    feeData.student_id,
    feeData.student_name,
    feeData.class_name,
    feeData.fee_month,
    feeData.payment_date,
    feeData.monthly_fee || 0,
    feeData.admission_fee || 0,
    feeData.registration_fee || 0,
    feeData.art_material || 0,
    feeData.transport || 0,
    feeData.books || 0,
    feeData.uniform || 0,
    feeData.fine || 0,
    feeData.others || 0,
    feeData.previous_balance || 0,
    feeData.total_amount || 0,
    feeData.due_balance || 0,
    feeData.deposit || 0,
  ];
  
  connection.query(query, values, callback);
};

// Get the latest due balance
export const getLatestDueBalance = (studentId, callback) => {
  const query = `
    SELECT due_balance 
    FROM fee_collections 
    WHERE student_id = ? 
    ORDER BY payment_date DESC, id DESC
    LIMIT 1
  `;
  connection.query(query, [studentId], (err, results) => {
    if (err) return callback(err);
    callback(null, results[0] || { due_balance: 0 });
  });
};

// Check if monthly fee has been paid for a specific month
export const checkMonthlyFeePaid = (studentId, month, callback) => {
  const query = `
    SELECT id, monthly_fee 
    FROM fee_collections 
    WHERE student_id = ? AND fee_month = ? AND monthly_fee > 0
    LIMIT 1
  `;
  connection.query(query, [studentId, month], (err, results) => {
    if (err) return callback(err);
    callback(null, results.length > 0);
  });
};

// Find fees by student ID
export const findFeesByStudentId = (studentId, callback) => {
  const query = `
    SELECT * FROM fee_collections 
    WHERE student_id = ? 
    ORDER BY payment_date DESC
  `;
  connection.query(query, [studentId], callback);
};

// Check if a specific fee type has been paid
export const checkFeesPaid = (studentId, feeType, callback) => {
  const query = `
    SELECT SUM(${feeType}) as total_paid
    FROM fee_collections 
    WHERE student_id = ?
  `;
    
  connection.query(query, [studentId], (err, results) => {
    if (err) return callback(err);
    // Consider fee as paid if the total amount paid is significant (e.g., > 100)
    // This allows for partial payments and later adjustments
    callback(null, results[0].total_paid > 100);
  });
};

// Get comprehensive fee summary by student
export const getFeeSummaryByStudent = (studentId, callback) => {
  const query = `
    SELECT 
      SUM(monthly_fee) as total_monthly_fee,
      SUM(admission_fee) as total_admission_fee,
      SUM(registration_fee) as total_registration_fee,
      SUM(art_material) as total_art_material,
      SUM(transport) as total_transport,
      SUM(books) as total_books,
      SUM(uniform) as total_uniform,
      SUM(fine) as total_fine,
      SUM(others) as total_others,
      SUM(deposit) as total_deposit,
      SUM(total_amount) as total_charged,
      (SELECT due_balance FROM fee_collections 
       WHERE student_id = ? 
       ORDER BY payment_date DESC, id DESC LIMIT 1) as last_due_balance,
      (SELECT fee_month FROM fee_collections 
       WHERE student_id = ? AND monthly_fee > 0
       ORDER BY payment_date DESC LIMIT 1) as last_payment_month
    FROM fee_collections
    WHERE student_id = ?
  `;
    
  connection.query(query, [studentId, studentId, studentId], callback);
};

// Get previous payments for a specific month
export const getPreviousPaymentsForMonth = (studentId, month, callback) => {
  const query = `
    SELECT * FROM fee_collections
    WHERE student_id = ? AND fee_month = ?
    ORDER BY payment_date DESC
  `;
  connection.query(query, [studentId, month], callback);
};