const { db } = require('./config/firebase');

async function checkChatHistory() {
    try {
        console.log('Checking chat_history collection...');
        const snapshot = await db.collection('chat_history').limit(5).get();

        if (snapshot.empty) {
            console.log('No documents found in chat_history.');
            return;
        }

        snapshot.forEach(doc => {
            console.log(`Document ID: ${doc.id}`);
            console.log('Data:', JSON.stringify(doc.data(), null, 2));
        });
    } catch (error) {
        console.error('Error checking chat_history:', error);
    } finally {
        process.exit();
    }
}

checkChatHistory();
