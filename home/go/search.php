<style>
.quick-search-container {
    padding: 26px;
    background: var(--background-primary);
    width: 100%;
    display: flex;
    justify-content: flex-end;
}

.quick-search-wrapper {
    position: relative;
    width: 50%;
    min-width: 200px;
    background: var(--background-primary);
    border: 1px solid #FF6A00;
    border-radius: 999px;
    transition: background 0.2s ease, box-shadow 0.2s ease;
}

.quick-search-wrapper:focus-within {
    background: var(--header-background);
}

.quick-search-input {
    width: 100%;
    background: transparent;
    border: none;
    border-radius: 999px;
    padding: 12px 50px 12px 20px;
    font-size: 1rem;
    color: var(--text-primary);
    outline: none;
    box-sizing: border-box;
}

.quick-search-wrapper:focus-within .quick-search-input {
    color: var(--text-primary);
}

.quick-search-button {
    position: absolute;
    right: 6px;                      /* Aligns button with the pill end */
    top: 50%;
    transform: translateY(-50%);
    width: 36px;                     /* Slightly smaller to fit inside pill */
    height: 36px;
    background: #FF6A00;
    border: none;
    border-radius: 50%;              /* Perfect circle */
    cursor: pointer;
    display: inline-flex;
    align-items: center;
    justify-content: center;
    transition: background 0.2s;
    margin: 0;
    padding: 0;
}

.quick-search-button:hover {
    background: #37475A;
}

.quick-search-button svg {
    width: 18px;
    height: 18px;
    display: block;
}
</style>

<?php
if ($DisableSearch != 1) {
    echo "<form name='FormSearch' method='POST' onsubmit=\"return SearchPost('$CurrentFileName');\" action='$CurrentFileName' style='overflow: visible; margin:0; padding:0;'>";
}
?>

<div class="quick-search-container">
    <div class="quick-search-wrapper">
        <input type="text"
               name="SearchFor"
               id="SearchFor"
               value="<?php echo htmlspecialchars($_REQUEST['SearchFor'] ?? '', ENT_QUOTES); ?>"
               placeholder="<?php echo htmlspecialchars($LNG['Search'] ?? 'Search', ENT_QUOTES); ?>"
               autocomplete="off"
               onkeyup="Search('tr')"
               onfocus="actb(this,event,customarray,'#FFFFFF','#000000','#c0c0c0','Tahoma','11px');"
               class="quick-search-input">

        <button type="submit"
                class="quick-search-button"
                aria-label="Search">
            <svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                <path d="M15.5 14H14.71L14.43 13.73C15.41 12.59 16 11.11 16 9.5C16 5.91 13.09 3 9.5 3C5.91 3 3 5.91 3 9.5C3 13.09 5.91 16 9.5 16C11.11 16 12.59 15.41 13.73 14.43L14 14.71V15.5L19 20.49L20.49 19L15.5 14ZM9.5 14C7.01 14 5 11.99 5 9.5C5 7.01 7.01 5 9.5 5C11.99 5 14 7.01 14 9.5C14 11.99 11.99 14 9.5 14Z" fill="white"/>
            </svg>
        </button>
    </div>
</div>

<?php
if ($DisableSearch != 1) {
    echo "</form>";
}
?>