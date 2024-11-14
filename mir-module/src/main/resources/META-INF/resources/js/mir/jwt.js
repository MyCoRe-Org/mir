export const fetchAccessToken = async (baseUrl) => {
  const response = await fetch(`${baseUrl}rsc/jwt`);
  if (!response.ok) {
    throw new Error('Failed to fetch JWT for current user.');
  }
  const result = await response.json();
  if (!result.login_success) {
    throw new Error('Login failed.');
  }
  return result.access_token;
}