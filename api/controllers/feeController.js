// import {
//     createFee,
//     findFeesByStudentId,
//     checkFeesPaid,
//     getFeeSummaryByStudent
//   } from '../models/feeModel.js';
  
//   export const submitFeePayment = (req, res) => {
//     const feeData = req.body;
    
//     // Calculate totals server-side
//     feeData.total_amount = 
//       (feeData.monthly_fee || 0) + 
//       (feeData.admission_fee || 0) + 
//       (feeData.registration_fee || 0) +
//       (feeData.art_material || 0) +
//       (feeData.transport || 0) +
//       (feeData.books || 0) +
//       (feeData.uniform || 0) +
//       (feeData.fine || 0) +
//       (feeData.others || 0);

//     feeData.deposit = (feeData.deposit || 0);

    
//     feeData.due_balance = (feeData.total_amount || 0) - feeData.deposit;
  
//     createFee(feeData, (err, result) => {
//       if (err) {
//         console.error('Error submitting fee payment:', err);
//         return res.status(500).json({
//           success: false,
//           message: 'Failed to record fee payment',
//           error: err.message
//         });
//       }
      
//       res.status(201).json({
//         success: true,
//         message: 'Fee payment recorded successfully',
//         data: { feeId: result.insertId }
//       });
//     });
//   };
  
//   export const getStudentFeeHistory = (req, res) => {
//     const { studentId } = req.params;
    
//     findFeesByStudentId(studentId, (err, results) => {
//       if (err) {
//         console.error('Error fetching fee history:', err);
//         return res.status(500).json({
//           success: false,
//           message: 'Failed to fetch fee history',
//           error: err.message
//         });
//       }
      
//       res.status(200).json({
//         success: true,
//         data: results
//       });
//     });
//   };
  
//   export const checkFeeEligibility = (req, res) => {
//     const { studentId } = req.params;
    
//     checkFeesPaid(studentId, 'admission_fee', (err, hasPaidAdmission) => {
//       if (err) return handleError(res, err);
      
//       checkFeesPaid(studentId, 'registration_fee', (err, hasPaidRegistration) => {
//         if (err) return handleError(res, err);
        
//         checkFeesPaid(studentId, 'uniform', (err, hasPaidUniform) => {
//           if (err) return handleError(res, err);
          
//           res.status(200).json({
//             success: true,
//             data: {
//               canCollectAdmissionFee: !hasPaidAdmission,
//               canCollectRegistrationFee: !hasPaidRegistration,
//               canCollectUniformFee: !hasPaidUniform
//             }
//           });
//         });
//       });
//     });
//   };
  
//   export const getFeeSummary = (req, res) => {
//     const { studentId } = req.params;
    
//     getFeeSummaryByStudent(studentId, (err, results) => {
//       if (err) {
//         console.error('Error fetching fee summary:', err);
//         return res.status(500).json({
//           success: false,
//           message: 'Failed to fetch fee summary',
//           error: err.message
//         });
//       }
      
//       res.status(200).json({
//         success: true,
//         data: results[0] || {}
//       });
//     });
//   };
  
//   function handleError(res, err) {
//     console.error('Error checking fee eligibility:', err);
//     return res.status(500).json({
//       success: false,
//       message: 'Failed to check fee eligibility',
//       error: err.message
//     });
//   }

// import {
//   createFee,
//   findFeesByStudentId,
//   checkFeesPaid,
//   getFeeSummaryByStudent,
//   getLatestDueBalance
// } from '../models/feeModel.js';

// export const submitFeePayment = async (req, res) => {
//   try {
//     const feeData = req.body;
    
//     // Get the latest due balance to use as previous balance
//     const latestDue = await new Promise((resolve, reject) => {
//       getLatestDueBalance(feeData.student_id, (err, result) => {
//         if (err) reject(err);
//         else resolve(result ? result.due_balance : 0);
//       });
//     });

//     // Calculate totals server-side
//     feeData.previous_balance = latestDue;
//     feeData.total_amount = 
//       (feeData.monthly_fee || 0) + 
//       (feeData.admission_fee || 0) + 
//       (feeData.registration_fee || 0) +
//       (feeData.art_material || 0) +
//       (feeData.transport || 0) +
//       (feeData.books || 0) +
//       (feeData.uniform || 0) +
//       (feeData.fine || 0) +
//       (feeData.others || 0) +
//       (feeData.previous_balance || 0);

//     feeData.deposit = (feeData.deposit || 0);
//     feeData.due_balance = feeData.total_amount - feeData.deposit;

//     createFee(feeData, (err, result) => {
//       if (err) {
//         console.error('Error submitting fee payment:', err);
//         return res.status(500).json({
//           success: false,
//           message: 'Failed to record fee payment',
//           error: err.message
//         });
//       }
      
//       res.status(201).json({
//         success: true,
//         message: 'Fee payment recorded successfully',
//         data: { feeId: result.insertId }
//       });
//     });
//   } catch (err) {
//     console.error('Error in submitFeePayment:', err);
//     res.status(500).json({
//       success: false,
//       message: 'Failed to process fee payment',
//       error: err.message
//     });
//   }
// };

// // ... (keep other functions the same)
//   export const getStudentFeeHistory = (req, res) => {
//     const { studentId } = req.params;
    
//     findFeesByStudentId(studentId, (err, results) => {
//       if (err) {
//         console.error('Error fetching fee history:', err);
//         return res.status(500).json({
//           success: false,
//           message: 'Failed to fetch fee history',
//           error: err.message
//         });
//       }
      
//       res.status(200).json({
//         success: true,
//         data: results
//       });
//     });
//   };
  
//   export const checkFeeEligibility = (req, res) => {
//     const { studentId } = req.params;
    
//     checkFeesPaid(studentId, 'admission_fee', (err, hasPaidAdmission) => {
//       if (err) return handleError(res, err);
      
//       checkFeesPaid(studentId, 'registration_fee', (err, hasPaidRegistration) => {
//         if (err) return handleError(res, err);
        
//         checkFeesPaid(studentId, 'uniform', (err, hasPaidUniform) => {
//           if (err) return handleError(res, err);
          
//           res.status(200).json({
//             success: true,
//             data: {
//               canCollectAdmissionFee: !hasPaidAdmission,
//               canCollectRegistrationFee: !hasPaidRegistration,
//               canCollectUniformFee: !hasPaidUniform
//             }
//           });
//         });
//       });
//     });
//   };
  
//   export const getFeeSummary = (req, res) => {
//     const { studentId } = req.params;
    
//     getFeeSummaryByStudent(studentId, (err, results) => {
//       if (err) {
//         console.error('Error fetching fee summary:', err);
//         return res.status(500).json({
//           success: false,
//           message: 'Failed to fetch fee summary',
//           error: err.message
//         });
//       }
      
//       res.status(200).json({
//         success: true,
//         data: results[0] || {}
//       });
//     });
//   };
  
//   function handleError(res, err) {
//     console.error('Error checking fee eligibility:', err);
//     return res.status(500).json({
//       success: false,
//       message: 'Failed to check fee eligibility',
//       error: err.message
//     });
//   }
import {
  createFee,
  findFeesByStudentId,
  checkFeesPaid,
  getFeeSummaryByStudent,
  getLatestDueBalance,
  checkMonthlyFeePaid,
  getPreviousPaymentsForMonth
} from '../models/feeModel.js';

// export const submitFeePayment = async (req, res) => {
//   try {
//     const feeData = req.body;
    
//     // Check if monthly fee for this month has already been paid
//     const monthlyFeePaid = await new Promise((resolve, reject) => {
//       checkMonthlyFeePaid(feeData.student_id, feeData.fee_month, (err, result) => {
//         if (err) reject(err);
//         else resolve(result);
//       });
//     });
    
//     // If trying to charge monthly fee again for the same month, return error
//     if (monthlyFeePaid && feeData.monthly_fee > 0) {
//       return res.status(400).json({
//         success: false,
//         message: 'Monthly Fee Of This Student is Already Added for This Month! So System will Not Add it Again.'
//       });
//     }
    
//     // Automatically set monthly fee to 0 if already paid for this month
//     if (monthlyFeePaid) {
//       feeData.monthly_fee = 0;
//     }
    
//     // Get the latest due balance to use as previous balance
//     const latestDue = await new Promise((resolve, reject) => {
//       getLatestDueBalance(feeData.student_id, (err, result) => {
//         if (err) reject(err);
//         else resolve(result ? result.due_balance : 0);
//       });
//     });
    
//     // Calculate totals server-side
//     feeData.previous_balance = latestDue;
//     feeData.total_amount = 
//        (feeData.monthly_fee || 0) +
//        (feeData.admission_fee || 0) +
//        (feeData.registration_fee || 0) +
//        (feeData.art_material || 0) +
//        (feeData.transport || 0) +
//        (feeData.books || 0) +
//        (feeData.uniform || 0) +
//        (feeData.fine || 0) +
//        (feeData.others || 0) +
//        (feeData.previous_balance || 0);
    
//     feeData.deposit = (feeData.deposit || 0);
//     feeData.due_balance = feeData.total_amount - feeData.deposit;
    
//     createFee(feeData, (err, result) => {
//       if (err) {
//         console.error('Error submitting fee payment:', err);
//         return res.status(500).json({
//           success: false,
//           message: 'Failed to record fee payment',
//           error: err.message
//         });
//       }
      
//       res.status(201).json({
//         success: true,
//         message: 'Fee payment recorded successfully',
//         data: { feeId: result.insertId }
//       });
//     });
//   } catch (err) {
//     console.error('Error in submitFeePayment:', err);
//     res.status(500).json({
//       success: false,
//       message: 'Failed to process fee payment',
//       error: err.message
//     });
//   }
// };
export const submitFeePayment = async (req, res) => {
  try {
    const feeData = req.body;
    
    // Check if monthly fee for this month has already been paid
    const monthlyFeePaid = await new Promise((resolve, reject) => {
      checkMonthlyFeePaid(feeData.student_id, feeData.fee_month, (err, result) => {
        if (err) reject(err);
        else resolve(result);
      });
    });
    
    // If trying to charge monthly fee again for the same month, return error
    if (monthlyFeePaid && feeData.monthly_fee > 0) {
      return res.status(400).json({
        success: false,
        message: 'Monthly Fee Of This Student is Already Added for This Month! So System will Not Add it Again.'
      });
    }
    
    // Automatically set monthly fee to 0 if already paid for this month
    if (monthlyFeePaid) {
      feeData.monthly_fee = 0;
    }
    
    // Get the latest due balance to use as previous balance
    const latestDue = await new Promise((resolve, reject) => {
      getLatestDueBalance(feeData.student_id, (err, result) => {
        if (err) reject(err);
        else resolve(result ? result.due_balance : 0);
      });
    });
    
    // Get previous payments for the same month to handle partial payments
    const previousPayments = await new Promise((resolve, reject) => {
      getPreviousPaymentsForMonth(feeData.student_id, feeData.fee_month, (err, result) => {
        if (err) reject(err);
        else resolve(result || []);
      });
    });
    
    // Check if this is a due payment for the same month (new transaction with only previous balance)
    const isDuePaymentForSameMonth = 
      previousPayments.length > 0 && 
      (feeData.monthly_fee === 0 || feeData.monthly_fee === "0") &&
      (feeData.admission_fee === 0 || feeData.admission_fee === "0") &&
      (feeData.registration_fee === 0 || feeData.registration_fee === "0") &&
      (feeData.art_material === 0 || feeData.art_material === "0") &&
      (feeData.transport === 0 || feeData.transport === "0") &&
      (feeData.books === 0 || feeData.books === "0") &&
      (feeData.uniform === 0 || feeData.uniform === "0") &&
      (feeData.fine === 0 || feeData.fine === "0") &&
      (feeData.others === 0 || feeData.others === "0") &&
      parseFloat(feeData.deposit || 0) > 0;
    
    // Set previous balance
    feeData.previous_balance = latestDue;
    
    // Calculate totals server-side
    // When it's just a payment against the existing due amount, don't add the amount again
    if (isDuePaymentForSameMonth) {
      feeData.total_amount = latestDue;
    } else {
      feeData.total_amount = 
         (parseFloat(feeData.monthly_fee) || 0) +
         (parseFloat(feeData.admission_fee) || 0) +
         (parseFloat(feeData.registration_fee) || 0) +
         (parseFloat(feeData.art_material) || 0) +
         (parseFloat(feeData.transport) || 0) +
         (parseFloat(feeData.books) || 0) +
         (parseFloat(feeData.uniform) || 0) +
         (parseFloat(feeData.fine) || 0) +
         (parseFloat(feeData.others) || 0) +
         (parseFloat(feeData.previous_balance) || 0);
    }
    
    feeData.deposit = (parseFloat(feeData.deposit) || 0);
    feeData.due_balance = parseFloat(feeData.total_amount) - parseFloat(feeData.deposit);
    
    createFee(feeData, (err, result) => {
      if (err) {
        console.error('Error submitting fee payment:', err);
        return res.status(500).json({
          success: false,
          message: 'Failed to record fee payment',
          error: err.message
        });
      }
      
      res.status(201).json({
        success: true,
        message: 'Fee payment recorded successfully',
        data: { feeId: result.insertId }
      });
    });
  } catch (err) {
    console.error('Error in submitFeePayment:', err);
    res.status(500).json({
      success: false,
      message: 'Failed to process fee payment',
      error: err.message
    });
  }
};
export const getStudentFeeHistory = (req, res) => {
  const { studentId } = req.params;
  
  findFeesByStudentId(studentId, (err, results) => {
    if (err) {
      console.error('Error fetching fee history:', err);
      return res.status(500).json({
        success: false,
        message: 'Failed to fetch fee history',
        error: err.message
      });
    }
    
    res.status(200).json({
      success: true,
      data: results
    });
  });
};

export const checkFeeEligibility = (req, res) => {
  const { studentId } = req.params;
  
  checkFeesPaid(studentId, 'admission_fee', (err, hasPaidAdmission) => {
    if (err) return handleError(res, err);
    
    checkFeesPaid(studentId, 'registration_fee', (err, hasPaidRegistration) => {
      if (err) return handleError(res, err);
      
      checkFeesPaid(studentId, 'uniform', (err, hasPaidUniform) => {
        if (err) return handleError(res, err);
        
        res.status(200).json({
          success: true,
          data: {
            canCollectAdmissionFee: !hasPaidAdmission,
            canCollectRegistrationFee: !hasPaidRegistration,
            canCollectUniformFee: !hasPaidUniform
          }
        });
      });
    });
  });
};

// export const getFeeSummary = (req, res) => {
//   const { studentId } = req.params;
  
//   getFeeSummaryByStudent(studentId, (err, results) => {
//     if (err) {
//       console.error('Error fetching fee summary:', err);
//       return res.status(500).json({
//         success: false,
//         message: 'Failed to fetch fee summary',
//         error: err.message
//       });
//     }
    
//     res.status(200).json({
//       success: true,
//       data: results[0] || {}
//     });
//   });
// };

export const getFeeSummary = (req, res) => {
  const { studentId } = req.params;
  
  getFeeSummaryByStudent(studentId, (err, results) => {
    if (err) {
      console.error('Error fetching fee summary:', err);
      return res.status(500).json({
        success: false,
        message: 'Failed to fetch fee summary',
        error: err.message
      });
    }
    
    res.status(200).json({
      success: true,
      data: results[0] || {}
    });
  });
};

export const getPreviousPaymentsForCurrentMonth = (req, res) => {
  const { studentId, month } = req.params;
  
  getPreviousPaymentsForMonth(studentId, month, (err, results) => {
    if (err) {
      console.error('Error fetching previous payments:', err);
      return res.status(500).json({
        success: false,
        message: 'Failed to fetch previous payments',
        error: err.message
      });
    }
    
    res.status(200).json({
      success: true,
      data: results
    });
  });
};

function handleError(res, err) {
  console.error('Error checking fee eligibility:', err);
  return res.status(500).json({
    success: false,
    message: 'Failed to check fee eligibility',
    error: err.message
  });
}