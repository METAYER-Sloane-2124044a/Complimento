const handler = async (event) => {
    console.log("Event reçu :", event);
    return {
        statusCode: 200,
        body: JSON.stringify({ message: "Hello from Lambda!" }),
    };
};

export default {
    handler,
};