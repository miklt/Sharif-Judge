import time
from selenium import webdriver


def login(driver, username, password):
    box = driver.find_element_by_name('username')
    box.send_keys(username)
    box = driver.find_element_by_name('password')
    box.send_keys(password)
    box.submit()
    time.sleep(2)
def clickScoreboard(driver):
    checkbox = driver.find_element_by_name('enable_scoreboard')
    checkbox.click()
    time.sleep(2)
    checkbox.submit()
def logout(driver):
    driver.get("http://localhost/Sharif-Judge/index.php/logout")
    time.sleep(2)
def TestForScoreboard(driver):
    login(driver, 'admin', '123456')
    driver.get("http://localhost/Sharif-Judge/index.php/settings")
    time.sleep(2)
    clickScoreboard(driver)
    driver.get('http://localhost/Sharif-Judge/index.php/dashboard')
    time.sleep(2)
    logout(driver)
    login(driver, 'aluno', '123456')
    logout(driver)
    login(driver, 'instructor', '123456')
    logout(driver)




driver = webdriver.Chrome()
driver.get('http://localhost/Sharif-Judge/index.php/login')
time.sleep(1)

TestForScoreboard(driver)
time.sleep(3)
TestForScoreboard(driver)
driver.quit()

