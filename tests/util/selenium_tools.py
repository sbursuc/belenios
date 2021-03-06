#!/usr/bin/python
# coding: utf-8
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.common.by import By
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import NoSuchElementException
from selenium.common.exceptions import StaleElementReferenceException


DEFAULT_WAIT_DURATION = 10 # In seconds


class element_has_non_empty_attribute(object):
    """
    An expectation for checking that an element has a non-empty value for given attribute.
    This class is meant to be used in combination with Selenium's `WebDriverWait::until()`. For example:
    ```
    custom_wait = WebDriverWait(browser, 10)
    smart_ballot_tracker_element = custom_wait.until(element_has_non_empty_attribute((By.ID, "my_id"), 'value'))
    ```

    :param locator: Selenium locator used to find the element. For example: `(By.ID, "my_id")`
    :param attribute: HTML attribute. For example 'innerText' (see `element_has_non_empty_content()` for this), or 'value'
    :return: The WebElement once it has a non-empty innerText attribute
    """
    def __init__(self, locator, attribute):
        self.locator = locator
        self.attribute = attribute

    def __call__(self, driver):
        element = driver.find_element(*self.locator)   # Finding the referenced element
        if not element:
            return False
        element_content = element.get_attribute(self.attribute).strip()
        if len(element_content) > 0:
            return element
        else:
            return False


class element_has_non_empty_content(element_has_non_empty_attribute):
    """
    An expectation for checking that an element has a non-empty innerText attribute.
    This class is meant to be used in combination with Selenium's `WebDriverWait::until()`. For example:
    ```
    custom_wait = WebDriverWait(browser, 10)
    smart_ballot_tracker_element = custom_wait.until(element_has_non_empty_content((By.ID, "my_id")))
    ```

    :param locator: Selenium locator used to find the element. For example: `(By.ID, "my_id")`
    :return: The WebElement once it has a non-empty innerText attribute
    """
    def __init__(self, locator):
        super().__init__(locator, 'innerText')


class an_element_with_partial_link_text_exists(object):
    def __init__(self, partial_link_text):
        self.partial_link_text = partial_link_text

    def __call__(self, driver):
        element = driver.find_element_by_partial_link_text(self.partial_link_text)
        if not element:
            return False
        return element


class element_exists_and_contains_expected_text(object):
    """
    An expectation for checking that an element exists and its innerText attribute contains expected text.
    This class is meant to be used in combination with Selenium's `WebDriverWait::until()`. For example:
    ```
    custom_wait = WebDriverWait(browser, 10)
    smart_ballot_tracker_element = custom_wait.until(element_exists_and_contains_expected_text((By.ID, "my_id"), "my expected text"))
    ```

    :param locator: Selenium locator used to find the element. For example: `(By.ID, "my_id")`
    :param expected_text: Text expected in element's innerText attribute (parameter type: string)
    :return: The WebElement once its innerText attribute contains expected_text
    """
    def __init__(self, locator, expected_text):
        self.locator = locator
        self.expected_text = expected_text

    def __call__(self, driver):
        element = driver.find_element(*self.locator)   # Finding the referenced element
        if not element:
            return False
        element_content = element.get_attribute('innerText').strip()
        if self.expected_text in element_content:
            return element
        else:
            return False


def wait_for_element_exists_and_contains_expected_text(browser, css_selector, expected_text, wait_duration=DEFAULT_WAIT_DURATION):
    """
    Waits for the presence of an element that matches CSS selector `css_selector` and that has an innerText attribute that contains string `expected_text`.
    :param browser: Selenium browser
    :param css_selector: CSS selector of the expected element
    :param expected_text: String of the expected text that element must contain
    :param wait_duration: Maximum duration in seconds that we wait for the presence of this element before raising an exception
    :return: The WebElement once it matches expected conditions
    """
    try:
        ignored_exceptions = (NoSuchElementException, StaleElementReferenceException,)
        custom_wait = WebDriverWait(browser, wait_duration, ignored_exceptions=ignored_exceptions)
        element = custom_wait.until(element_exists_and_contains_expected_text((By.CSS_SELECTOR, css_selector), expected_text))
        return element
    except Exception as e:
        raise Exception("Could not find expected DOM element '" + css_selector + "' with text content '" + expected_text + "' until timeout of " + str(wait_duration) + " seconds. Page source was: " + str(browser.page_source.encode("utf-8"))) from e


def wait_for_element_exists_and_has_non_empty_attribute(browser, css_selector, attribute, wait_duration=DEFAULT_WAIT_DURATION):
    try:
        ignored_exceptions = (NoSuchElementException, StaleElementReferenceException,)
        custom_wait = WebDriverWait(browser, wait_duration, ignored_exceptions=ignored_exceptions)
        element = custom_wait.until(element_has_non_empty_attribute((By.CSS_SELECTOR, css_selector), attribute))
        return element
    except Exception as e:
        raise Exception("Could not find expected DOM element '" + css_selector + "' with non-empty attribute '" + attribute + "' until timeout of " + str(wait_duration) + " seconds") from e


def wait_for_element_exists_and_has_non_empty_content(browser, css_selector, wait_duration=DEFAULT_WAIT_DURATION):
    return wait_for_element_exists_and_has_non_empty_attribute(browser, css_selector, 'innerText', wait_duration)


def wait_for_an_element_with_partial_link_text_exists(browser, partial_link_text, wait_duration=DEFAULT_WAIT_DURATION):
    try:
        ignored_exceptions = (NoSuchElementException, StaleElementReferenceException,)
        custom_wait = WebDriverWait(browser, wait_duration, ignored_exceptions=ignored_exceptions)
        element = custom_wait.until(an_element_with_partial_link_text_exists(partial_link_text))
        return element
    except Exception as e:
        raise Exception("Could not find a DOM element that contains expected partial link text '" + partial_link_text + "' until timeout of " + str(wait_duration) + " seconds") from e


def wait_for_element_exists(browser, css_selector, wait_duration=DEFAULT_WAIT_DURATION):
    try:
        return WebDriverWait(browser, wait_duration).until(
            EC.presence_of_element_located((By.CSS_SELECTOR, css_selector))
        )
    except Exception as e:
        raise Exception("Could not find expected DOM element '" + css_selector + "' until timeout of " + str(wait_duration) + " seconds") from e


def wait_for_elements_exist(browser, css_selector, wait_duration=DEFAULT_WAIT_DURATION):
    try:
        return WebDriverWait(browser, wait_duration).until(
            EC.presence_of_all_elements_located((By.CSS_SELECTOR, css_selector))
        )
    except Exception as e:
        raise Exception("Could not find expected DOM elements '" + css_selector + "' until timeout of " + str(wait_duration) + " seconds") from e


def set_element_attribute(browser, element_dom_id, attribute_key, attribute_value):
    browser.execute_script("let el = document.getElementById('" + element_dom_id + "'); el.setAttribute('" + attribute_key + "','" + attribute_value + "');")


def verify_element_label(element, expected_label):
    element_real_label = element.get_attribute('innerText')
    assert expected_label in element_real_label, 'Expected label "' + expected_label + '" not found in element label "' + element_real_label + "'"
