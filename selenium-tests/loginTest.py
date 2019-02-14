import time
from selenium import webdriver

driver = webdriver.Chrome()  # Optional argument, if not specified will search path.
driver.get('http://localhost/Sharif-Judge/index.php/login')
time.sleep(5) # Let the user actually see something!
search_box = driver.find_element_by_name('username')
search_box.send_keys('aluno')
search_box = driver.find_element_by_name('password')
search_box.send_keys('123456')
search_box.submit()
time.sleep(5) # Let the user actually see something!
driver.quit()
